import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'device_repository.dart';
import 'api_service.dart';
import 'notification_service.dart';
import 'weather_alert_service.dart';
import 'widget_service.dart';
import 'auth_service.dart';

class DeviceProvider extends ChangeNotifier {
  final DeviceRepository _repo;
  final ApiService _api;
  final WeatherAlertService _alertService;
  final AuthService? _auth;

  List<Device> _devices = [];
  final Map<String, Measurement?> _measurements = {};
  final Map<String, bool> _loading = {};
  final Map<String, String?> _errors = {};
  final Map<String, List<MeasurementPoint>> _sparklines = {};
  final Map<String, List<MeasurementPoint>> _history = {};

  final Set<String> _activeFrostAlarms = {};
  final Set<String> _activeBatteryAlarms = {};

  List<int> _activeWidgetIds = [];
  final Map<int, Map<String, dynamic>> _widgetConfigs = {};

  List<Device> get devices => List.unmodifiable(_devices);
  List<int> get activeWidgetIds => _activeWidgetIds;

  Measurement? measurementFor(String deviceId) => _measurements[deviceId];
  bool isLoading(String deviceId) => _loading[deviceId] ?? false;
  String? errorFor(String deviceId) => _errors[deviceId];
  List<MeasurementPoint> historyFor(String deviceId) => _history[deviceId] ?? [];

  DeviceProvider({
    DeviceRepository? repo, 
    ApiService? api, 
    NotificationService? notificationService,
    AuthService? authService,
  }) : _repo = repo ?? DeviceRepository(),
       _api = api ?? ApiService(),
       _alertService = WeatherAlertService(notificationService ?? NotificationService()),
       _auth = authService;

  Future<void> loadDevices() async {
    _devices = await _repo.loadAll();
    await loadWidgetConfigs();
    notifyListeners();
    // Startet die Abfrage im Hintergrund, ohne die UI zu blockieren
    refreshAll();
  }

  Future<void> loadWidgetConfigs() async {
    _activeWidgetIds = await WidgetService.getActiveWidgetIds();
    final prefs = await SharedPreferences.getInstance();
    
    for (final id in _activeWidgetIds) {
      final raw = prefs.getString('widget_config_$id');
      if (raw != null) {
        _widgetConfigs[id] = jsonDecode(raw) as Map<String, dynamic>;
      }
    }
  }

  Future<void> setWidgetConfig(int widgetId, String deviceId, List<String> metrics) async {
    await WidgetService.saveConfig(widgetId, deviceId, metrics);
    await loadWidgetConfigs();
    notifyListeners();
    
    final device = _devices.firstWhere((d) => d.id == deviceId);
    final m = _measurements[deviceId];
    if (m != null) {
      await WidgetService.updateWidget(widgetId, device, m, metrics: metrics);
    }
  }

  Map<String, dynamic>? getConfigForWidget(int widgetId) => _widgetConfigs[widgetId];

  Future<void> refreshAll() async {
    // Wir führen die Abfragen nacheinander durch (sequential),
    // um den Server/Netzwerk bei vielen Geräten nicht zu überlasten.
    for (final device in _devices) {
      await refreshDevice(device.id);
    }
  }

  Future<void> refreshDevice(String id) async {
    try {
      final device = _devices.firstWhere((d) => d.id == id);
      _loading[id] = true;
      _errors[id] = null;
      notifyListeners();

      // Automatische Slug-Erkennung, falls leer
      Device currentDevice = device;
      if (currentDevice.stationSlug.isEmpty) {
        final token = _auth?.currentUser?.token;
        final stationsResult = await _api.fetchStations(currentDevice, bearerToken: token);
        if (stationsResult.data != null && stationsResult.data!.isNotEmpty) {
          final discoveredSlug = stationsResult.data!.first['slug']?.toString();
          if (discoveredSlug != null && discoveredSlug.isNotEmpty) {
            currentDevice = currentDevice.copyWith(stationSlug: discoveredSlug);
            await _repo.update(currentDevice);
            final idx = _devices.indexWhere((d) => d.id == id);
            if (idx >= 0) _devices[idx] = currentDevice;
          }
        }
      }

      final result = await _api.fetchLatest(currentDevice);
      
      if (result.error != null) {
        _errors[id] = result.error;
      } else {
        final measurement = result.data!;
        _measurements[id] = measurement;
        
        for (final widgetId in _activeWidgetIds) {
          final config = _widgetConfigs[widgetId];
          if (config != null && config['deviceId'] == id) {
            final metrics = (config['metrics'] as List?)?.cast<String>() ?? ['humidity'];
            await WidgetService.updateWidget(widgetId, device, measurement, metrics: metrics);
          }
        }

        _checkAlarms(device, measurement);
        _loadSparkline(device);
      }
    } catch (_) {} finally {
      _loading[id] = false;
      notifyListeners();
    }
  }

  void _checkAlarms(Device device, Measurement m) {
    final alerts = _alertService.checkAlarms(
      device: device,
      measurement: m,
      activeFrostAlarms: _activeFrostAlarms,
      activeBatteryAlarms: _activeBatteryAlarms,
    );
    if (alerts.isNotEmpty) {
      _errors[device.id] = alerts.first;
    }
  }

  Future<void> loadFullHistory(String deviceId, {int hours = 24}) async {
    final device = _devices.firstWhere((d) => d.id == deviceId);
    final token = _auth?.currentUser?.token;
    final result = await _api.fetchHistory(device, hours: hours, bearerToken: token);
    if (result.data != null) {
      _history[deviceId] = result.data!;
      notifyListeners();
    } else if (result.error != null) {
      throw Exception(result.error);
    }
  }

  Future<void> _loadSparkline(Device device) async {
    final token = _auth?.currentUser?.token;
    final result = await _api.fetchHistory(device, hours: 24, bearerToken: token);
    if (result.data != null) {
      _sparklines[device.id] = result.data!;
      notifyListeners();
    }
  }

  List<MeasurementPoint> sparklineFor(String deviceId) => _sparklines[deviceId] ?? [];

  Future<void> addDevice(Device device) async {
    await _repo.add(device);
    _devices = await _repo.loadAll();
    notifyListeners();
    await refreshDevice(device.id);
  }

  Future<ApiResult<void>> updateDevice(Device newDevice) async {
    try {
      final oldDevice = _devices.firstWhere((d) => d.id == newDevice.id, orElse: () => newDevice);
      if (oldDevice.name != newDevice.name || oldDevice.stationSlug != newDevice.stationSlug) {
        final token = _auth?.currentUser?.token;
        if (token != null) {
          final apiResult = await _api.updateStation(oldDevice, currentSlug: oldDevice.stationSlug, name: newDevice.name, newSlug: newDevice.stationSlug, bearerToken: token);
          if (apiResult.error != null) return (data: null, error: apiResult.error);
        }
      }
      await _repo.update(newDevice);
      _devices = await _repo.loadAll();
      notifyListeners();
      await refreshDevice(newDevice.id);
      return (data: null, error: null);
    } catch (e) {
      return (data: null, error: 'Interner Fehler beim Speichern: $e');
    }
  }

  Future<void> removeDevice(String id) async {
    await _repo.remove(id);
    _devices.removeWhere((d) => d.id == id);
    _measurements.remove(id);
    _loading.remove(id);
    _errors.remove(id);
    _sparklines.remove(id);
    _activeFrostAlarms.remove(id);
    _activeBatteryAlarms.remove(id);
    notifyListeners();
  }
}
