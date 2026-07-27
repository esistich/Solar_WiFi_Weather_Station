// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Solar Weather';

  @override
  String get addDevice => 'Gerät hinzufügen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get noDevices => 'Noch keine Geräte';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get welcomeBack => 'Willkommen zurück';

  @override
  String get notLoggedIn => 'Nicht angemeldet';

  @override
  String get loginForCloudFeatures => 'Für Cloud-Features einloggen';

  @override
  String get deviceManagement => 'Geräteverwaltung';

  @override
  String get addNewStation => 'Neue Station hinzufügen';

  @override
  String get noActiveWidgets =>
      'Keine aktiven Widgets auf dem Homescreen gefunden.';

  @override
  String get appAppearance => 'App & Darstellung';

  @override
  String get darkMode => 'Dunkles Design';

  @override
  String get darkModeSubtitle => 'Schont die Augen bei Nacht';

  @override
  String get aboutApp => 'Über diese App';

  @override
  String get login => 'Anmelden';

  @override
  String get logout => 'Abmelden';

  @override
  String get editDevice => 'Gerät anpassen';

  @override
  String get newDevice => 'Neues Gerät';

  @override
  String get startSetup => 'Einrichtung starten';

  @override
  String get setupMethodSelection =>
      'Wie möchtest du deine Wetterstation verbinden?';

  @override
  String get autoSetup => 'Automatisches Setup';

  @override
  String get autoSetupSubtitle =>
      'Empfohlen: App sendet WLAN-Daten direkt an das Gerät.';

  @override
  String get manualSetup => 'Manuelle Eingabe';

  @override
  String get manualSetupSubtitle =>
      'Direkte Eingabe der API-URL (für Fortgeschrittene).';

  @override
  String get prepareDevice => 'Gerät vorbereiten';

  @override
  String get prepareDeviceInstructions =>
      '1. Halte den Button am Gerät für 2 Sek. gedrückt.\n2. Warte bis die LED blinkt.\n3. Gib hier deine WLAN-Daten ein.';

  @override
  String get wifiName => 'WLAN Name (SSID)';

  @override
  String get wifiPassword => 'WLAN Passwort';

  @override
  String get continueToApi => 'Weiter zur API-Konfiguration';

  @override
  String get deviceName => 'Gerätename';

  @override
  String get serverAddress => 'Server Adresse';

  @override
  String get apiPath => 'API Pfad';

  @override
  String get stationSlug => 'Station Slug (optional)';

  @override
  String get secureConnection => 'Sichere Verbindung (HTTPS)';

  @override
  String get stationSymbol => 'Station Symbol';

  @override
  String get finishSetup => 'Einrichtung abschließen';

  @override
  String get saving => 'Speichere...';

  @override
  String get setupSuccess => 'Alles bereit!';

  @override
  String setupSuccessMessage(String name) {
    return 'Die Station \"$name\" wurde erfolgreich eingerichtet.';
  }

  @override
  String get toDashboard => 'Zum Dashboard';

  @override
  String get history => 'Verlauf';

  @override
  String get apiConfiguration => 'API Konfiguration';

  @override
  String get historyProtected => 'Historie geschützt';

  @override
  String get loginToSeeHistory =>
      'Um den Verlauf zu sehen, musst du dich anmelden.';

  @override
  String get loginNow => 'Jetzt anmelden';

  @override
  String get noHistoryData => 'Keine Daten für diesen Zeitraum vorhanden.';

  @override
  String get temperature => 'Temperatur';

  @override
  String get humidity => 'Feuchte';

  @override
  String get pressure => 'Luftdruck';

  @override
  String get forecast => 'Vorhersage';

  @override
  String get pressureTrend => 'Drucktrend';

  @override
  String get battery => 'Batterie';

  @override
  String get configureStation => 'Station konfigurieren';

  @override
  String get displayName => 'Anzeigename';

  @override
  String get stationSlugApi => 'Station Slug (API)';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get changesSaved => 'Änderungen erfolgreich gespeichert.';

  @override
  String get noDataAvailable => 'Keine Daten verfügbar';

  @override
  String get pool => 'Pool';

  @override
  String get relativeTimeJustNow => 'gerade eben';

  @override
  String relativeTimeMinutes(int count) {
    return 'vor $count Min.';
  }

  @override
  String relativeTimeHours(int count) {
    return 'vor $count Std.';
  }

  @override
  String relativeTimeDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Tagen',
      one: 'vor einem Tag',
    );
    return '$_temp0';
  }

  @override
  String get sensorLabelForecastAccuracy => 'Prognosegenauigkeit';

  @override
  String get sensorLabelDewpoint => 'Taupunkt';

  @override
  String get sensorLabelHeatIndex => 'Hitzeindex';

  @override
  String get sensorLabelVoltage => 'Spannung';

  @override
  String get sensorLabelWifi => 'WLAN';

  @override
  String get sensorLabelAbsPressure => 'Luftdruck (abs.)';

  @override
  String get sensorLabelFwVersion => 'FW Version';

  @override
  String get sensorLabelCo2 => 'CO2';

  @override
  String get sensorLabelDust => 'Feinstaub';

  @override
  String get sensorLabelBrightness => 'Helligkeit';

  @override
  String get sensorLabelUvIndex => 'UV-Index';

  @override
  String get deviceIconLabelHouse => 'Haus';

  @override
  String get deviceIconLabelPool => 'Pool';

  @override
  String get deviceIconLabelGarden => 'Garten';

  @override
  String get deviceIconLabelBalcony => 'Balkon';

  @override
  String get deviceIconLabelRoof => 'Dach';

  @override
  String get deviceIconLabelGarage => 'Garage';

  @override
  String get deviceIconLabelCabin => 'Hütte';

  @override
  String get deviceIconLabelGeneral => 'Allgemein';
}
