import 'dart:convert';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'firebase_options.dart';
import 'services/services.dart';
import 'screens/home_screen.dart';

const String syncTaskName = "net.timm_sander.sws.syncTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await _handleBackgroundSync();
    } catch (e) {
      debugPrint("Background Task Error: $e");
    }
    return Future.value(true);
  });
}

Future<void> _handleBackgroundSync() async {
  final notificationService = NotificationService();
  await notificationService.init();
  final alertService = WeatherAlertService(notificationService);

  final repo = DeviceRepository();
  final api = ApiService();
  final prefs = await SharedPreferences.getInstance();

  final devices = await repo.loadAll();
  final activeWidgetIds = await WidgetService.getActiveWidgetIds();

  for (final device in devices) {
    final result = await api.fetchLatest(device);
    final measurement = result.data;
    if (measurement != null) {
      // Update Widgets
      for (final widgetId in activeWidgetIds) {
        final configRaw = prefs.getString('widget_config_$widgetId');
        if (configRaw != null) {
          final config = jsonDecode(configRaw) as Map<String, dynamic>;
          if (config['deviceId'] == device.id) {
            final metrics = (config['metrics'] as List?)?.cast<String>() ?? ['humidity'];
            await WidgetService.updateWidget(widgetId, device, measurement, metrics: metrics);
          }
        }
      }

      // Check Alarms
      alertService.checkAlarms(
        device: device,
        measurement: measurement,
        notify: true,
      );
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-Edge Support
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    "1", syncTaskName, frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final authService = AuthService();
  await authService.init();

  final pushService = PushService(authService);
  await pushService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  final deviceProvider = DeviceProvider(
    notificationService: notificationService,
    authService: authService,
  );
  // Wir laden nur die Liste aus dem Speicher, die Netzwerk-Abfragen
  // laufen asynchron im Hintergrund weiter, um den Start nicht zu blockieren.
  unawaited(deviceProvider.loadDevices());

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: deviceProvider),
        Provider.value(value: pushService),
        Provider.value(value: notificationService),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const SwsApp(),
    ),
  );
}

class SwsApp extends StatelessWidget {
  const SwsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'Solar Weather',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.mode,
          theme: themeProvider.buildTheme(Brightness.light, lightDynamic),
          darkTheme: themeProvider.buildTheme(Brightness.dark, darkDynamic),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('de'),
          ],
          home: const HomeScreen(),
        );
      },
    );
  }
}
