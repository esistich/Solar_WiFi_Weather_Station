import '../models/models.dart';
import 'notification_service.dart';

class WeatherAlertService {
  final NotificationService _notificationService;

  WeatherAlertService(this._notificationService);

  /// Prüft Messwerte auf Frost oder schwachen Akku und löst Benachrichtigungen aus.
  /// Gibt eine Liste von Fehlermeldungen zurück, die für dieses Gerät relevant sind.
  List<String> checkAlarms({
    required Device device,
    required Measurement measurement,
    Set<String>? activeFrostAlarms,
    Set<String>? activeBatteryAlarms,
    bool notify = true,
  }) {
    final errors = <String>[];

    // Frostwarnung
    if (measurement.temperature <= 3.0) {
      errors.add('⚠️ FROSTWARNUNG: ${measurement.temperature.toStringAsFixed(1)}°C');
      if (notify && (activeFrostAlarms == null || !activeFrostAlarms.contains(device.id))) {
        _notificationService.showAlarm(
          id: device.id.hashCode + 1,
          title: 'Frostgefahr! ❄️',
          body: 'Station "${device.name}" meldet ${measurement.temperature.toStringAsFixed(1)}°C.',
        );
        activeFrostAlarms?.add(device.id);
      }
    } else {
      activeFrostAlarms?.remove(device.id);
    }

    // Akkuwarnung
    if (measurement.batteryPct <= 20) {
      errors.add('🪫 AKKU SCHWACH: ${measurement.batteryPct}%');
      if (notify && (activeBatteryAlarms == null || !activeBatteryAlarms.contains(device.id))) {
        _notificationService.showAlarm(
          id: device.id.hashCode + 2,
          title: 'Akku fast leer! 🪫',
          body: 'Station "${device.name}" hat nur noch ${measurement.batteryPct}% Akku.',
        );
        activeBatteryAlarms?.add(device.id);
      }
    } else {
      activeBatteryAlarms?.remove(device.id);
    }

    return errors;
  }
}
