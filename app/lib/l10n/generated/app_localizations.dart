import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de')];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Solar Weather'**
  String get appTitle;

  /// No description provided for @addDevice.
  ///
  /// In de, this message translates to:
  /// **'Gerät hinzufügen'**
  String get addDevice;

  /// No description provided for @settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// No description provided for @noDevices.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Geräte'**
  String get noDevices;

  /// No description provided for @refresh.
  ///
  /// In de, this message translates to:
  /// **'Aktualisieren'**
  String get refresh;

  /// No description provided for @welcomeBack.
  ///
  /// In de, this message translates to:
  /// **'Willkommen zurück'**
  String get welcomeBack;

  /// No description provided for @notLoggedIn.
  ///
  /// In de, this message translates to:
  /// **'Nicht angemeldet'**
  String get notLoggedIn;

  /// No description provided for @loginForCloudFeatures.
  ///
  /// In de, this message translates to:
  /// **'Für Cloud-Features einloggen'**
  String get loginForCloudFeatures;

  /// No description provided for @deviceManagement.
  ///
  /// In de, this message translates to:
  /// **'Geräteverwaltung'**
  String get deviceManagement;

  /// No description provided for @addNewStation.
  ///
  /// In de, this message translates to:
  /// **'Neue Station hinzufügen'**
  String get addNewStation;

  /// No description provided for @noActiveWidgets.
  ///
  /// In de, this message translates to:
  /// **'Keine aktiven Widgets auf dem Homescreen gefunden.'**
  String get noActiveWidgets;

  /// No description provided for @appAppearance.
  ///
  /// In de, this message translates to:
  /// **'App & Darstellung'**
  String get appAppearance;

  /// No description provided for @darkMode.
  ///
  /// In de, this message translates to:
  /// **'Dunkles Design'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Schont die Augen bei Nacht'**
  String get darkModeSubtitle;

  /// No description provided for @aboutApp.
  ///
  /// In de, this message translates to:
  /// **'Über diese App'**
  String get aboutApp;

  /// No description provided for @login.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get logout;

  /// No description provided for @editDevice.
  ///
  /// In de, this message translates to:
  /// **'Gerät anpassen'**
  String get editDevice;

  /// No description provided for @newDevice.
  ///
  /// In de, this message translates to:
  /// **'Neues Gerät'**
  String get newDevice;

  /// No description provided for @startSetup.
  ///
  /// In de, this message translates to:
  /// **'Einrichtung starten'**
  String get startSetup;

  /// No description provided for @setupMethodSelection.
  ///
  /// In de, this message translates to:
  /// **'Wie möchtest du deine Wetterstation verbinden?'**
  String get setupMethodSelection;

  /// No description provided for @autoSetup.
  ///
  /// In de, this message translates to:
  /// **'Automatisches Setup'**
  String get autoSetup;

  /// No description provided for @autoSetupSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Empfohlen: App sendet WLAN-Daten direkt an das Gerät.'**
  String get autoSetupSubtitle;

  /// No description provided for @manualSetup.
  ///
  /// In de, this message translates to:
  /// **'Manuelle Eingabe'**
  String get manualSetup;

  /// No description provided for @manualSetupSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Direkte Eingabe der API-URL (für Fortgeschrittene).'**
  String get manualSetupSubtitle;

  /// No description provided for @prepareDevice.
  ///
  /// In de, this message translates to:
  /// **'Gerät vorbereiten'**
  String get prepareDevice;

  /// No description provided for @prepareDeviceInstructions.
  ///
  /// In de, this message translates to:
  /// **'1. Halte den Button am Gerät für 2 Sek. gedrückt.\n2. Warte bis die LED blinkt.\n3. Gib hier deine WLAN-Daten ein.'**
  String get prepareDeviceInstructions;

  /// No description provided for @wifiName.
  ///
  /// In de, this message translates to:
  /// **'WLAN Name (SSID)'**
  String get wifiName;

  /// No description provided for @wifiPassword.
  ///
  /// In de, this message translates to:
  /// **'WLAN Passwort'**
  String get wifiPassword;

  /// No description provided for @continueToApi.
  ///
  /// In de, this message translates to:
  /// **'Weiter zur API-Konfiguration'**
  String get continueToApi;

  /// No description provided for @deviceName.
  ///
  /// In de, this message translates to:
  /// **'Gerätename'**
  String get deviceName;

  /// No description provided for @serverAddress.
  ///
  /// In de, this message translates to:
  /// **'Server Adresse'**
  String get serverAddress;

  /// No description provided for @apiPath.
  ///
  /// In de, this message translates to:
  /// **'API Pfad'**
  String get apiPath;

  /// No description provided for @stationSlug.
  ///
  /// In de, this message translates to:
  /// **'Station Slug (optional)'**
  String get stationSlug;

  /// No description provided for @secureConnection.
  ///
  /// In de, this message translates to:
  /// **'Sichere Verbindung (HTTPS)'**
  String get secureConnection;

  /// No description provided for @stationSymbol.
  ///
  /// In de, this message translates to:
  /// **'Station Symbol'**
  String get stationSymbol;

  /// No description provided for @finishSetup.
  ///
  /// In de, this message translates to:
  /// **'Einrichtung abschließen'**
  String get finishSetup;

  /// No description provided for @saving.
  ///
  /// In de, this message translates to:
  /// **'Speichere...'**
  String get saving;

  /// No description provided for @setupSuccess.
  ///
  /// In de, this message translates to:
  /// **'Alles bereit!'**
  String get setupSuccess;

  /// No description provided for @setupSuccessMessage.
  ///
  /// In de, this message translates to:
  /// **'Die Station \"{name}\" wurde erfolgreich eingerichtet.'**
  String setupSuccessMessage(String name);

  /// No description provided for @toDashboard.
  ///
  /// In de, this message translates to:
  /// **'Zum Dashboard'**
  String get toDashboard;

  /// No description provided for @history.
  ///
  /// In de, this message translates to:
  /// **'Verlauf'**
  String get history;

  /// No description provided for @apiConfiguration.
  ///
  /// In de, this message translates to:
  /// **'API Konfiguration'**
  String get apiConfiguration;

  /// No description provided for @historyProtected.
  ///
  /// In de, this message translates to:
  /// **'Historie geschützt'**
  String get historyProtected;

  /// No description provided for @loginToSeeHistory.
  ///
  /// In de, this message translates to:
  /// **'Um den Verlauf zu sehen, musst du dich anmelden.'**
  String get loginToSeeHistory;

  /// No description provided for @loginNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt anmelden'**
  String get loginNow;

  /// No description provided for @noHistoryData.
  ///
  /// In de, this message translates to:
  /// **'Keine Daten für diesen Zeitraum vorhanden.'**
  String get noHistoryData;

  /// No description provided for @temperature.
  ///
  /// In de, this message translates to:
  /// **'Temperatur'**
  String get temperature;

  /// No description provided for @humidity.
  ///
  /// In de, this message translates to:
  /// **'Feuchte'**
  String get humidity;

  /// No description provided for @pressure.
  ///
  /// In de, this message translates to:
  /// **'Luftdruck'**
  String get pressure;

  /// No description provided for @forecast.
  ///
  /// In de, this message translates to:
  /// **'Vorhersage'**
  String get forecast;

  /// No description provided for @pressureTrend.
  ///
  /// In de, this message translates to:
  /// **'Drucktrend'**
  String get pressureTrend;

  /// No description provided for @battery.
  ///
  /// In de, this message translates to:
  /// **'Batterie'**
  String get battery;

  /// No description provided for @configureStation.
  ///
  /// In de, this message translates to:
  /// **'Station konfigurieren'**
  String get configureStation;

  /// No description provided for @displayName.
  ///
  /// In de, this message translates to:
  /// **'Anzeigename'**
  String get displayName;

  /// No description provided for @stationSlugApi.
  ///
  /// In de, this message translates to:
  /// **'Station Slug (API)'**
  String get stationSlugApi;

  /// No description provided for @saveChanges.
  ///
  /// In de, this message translates to:
  /// **'Änderungen speichern'**
  String get saveChanges;

  /// No description provided for @changesSaved.
  ///
  /// In de, this message translates to:
  /// **'Änderungen erfolgreich gespeichert.'**
  String get changesSaved;

  /// No description provided for @noDataAvailable.
  ///
  /// In de, this message translates to:
  /// **'Keine Daten verfügbar'**
  String get noDataAvailable;

  /// No description provided for @pool.
  ///
  /// In de, this message translates to:
  /// **'Pool'**
  String get pool;

  /// No description provided for @relativeTimeJustNow.
  ///
  /// In de, this message translates to:
  /// **'gerade eben'**
  String get relativeTimeJustNow;

  /// No description provided for @relativeTimeMinutes.
  ///
  /// In de, this message translates to:
  /// **'vor {count} Min.'**
  String relativeTimeMinutes(int count);

  /// No description provided for @relativeTimeHours.
  ///
  /// In de, this message translates to:
  /// **'vor {count} Std.'**
  String relativeTimeHours(int count);

  /// No description provided for @relativeTimeDays.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{vor einem Tag} other{vor {count} Tagen}}'**
  String relativeTimeDays(int count);

  /// No description provided for @sensorLabelForecastAccuracy.
  ///
  /// In de, this message translates to:
  /// **'Prognosegenauigkeit'**
  String get sensorLabelForecastAccuracy;

  /// No description provided for @sensorLabelDewpoint.
  ///
  /// In de, this message translates to:
  /// **'Taupunkt'**
  String get sensorLabelDewpoint;

  /// No description provided for @sensorLabelHeatIndex.
  ///
  /// In de, this message translates to:
  /// **'Hitzeindex'**
  String get sensorLabelHeatIndex;

  /// No description provided for @sensorLabelVoltage.
  ///
  /// In de, this message translates to:
  /// **'Spannung'**
  String get sensorLabelVoltage;

  /// No description provided for @sensorLabelWifi.
  ///
  /// In de, this message translates to:
  /// **'WLAN'**
  String get sensorLabelWifi;

  /// No description provided for @sensorLabelAbsPressure.
  ///
  /// In de, this message translates to:
  /// **'Luftdruck (abs.)'**
  String get sensorLabelAbsPressure;

  /// No description provided for @sensorLabelFwVersion.
  ///
  /// In de, this message translates to:
  /// **'FW Version'**
  String get sensorLabelFwVersion;

  /// No description provided for @sensorLabelCo2.
  ///
  /// In de, this message translates to:
  /// **'CO2'**
  String get sensorLabelCo2;

  /// No description provided for @sensorLabelDust.
  ///
  /// In de, this message translates to:
  /// **'Feinstaub'**
  String get sensorLabelDust;

  /// No description provided for @sensorLabelBrightness.
  ///
  /// In de, this message translates to:
  /// **'Helligkeit'**
  String get sensorLabelBrightness;

  /// No description provided for @sensorLabelUvIndex.
  ///
  /// In de, this message translates to:
  /// **'UV-Index'**
  String get sensorLabelUvIndex;

  /// No description provided for @deviceIconLabelHouse.
  ///
  /// In de, this message translates to:
  /// **'Haus'**
  String get deviceIconLabelHouse;

  /// No description provided for @deviceIconLabelPool.
  ///
  /// In de, this message translates to:
  /// **'Pool'**
  String get deviceIconLabelPool;

  /// No description provided for @deviceIconLabelGarden.
  ///
  /// In de, this message translates to:
  /// **'Garten'**
  String get deviceIconLabelGarden;

  /// No description provided for @deviceIconLabelBalcony.
  ///
  /// In de, this message translates to:
  /// **'Balkon'**
  String get deviceIconLabelBalcony;

  /// No description provided for @deviceIconLabelRoof.
  ///
  /// In de, this message translates to:
  /// **'Dach'**
  String get deviceIconLabelRoof;

  /// No description provided for @deviceIconLabelGarage.
  ///
  /// In de, this message translates to:
  /// **'Garage'**
  String get deviceIconLabelGarage;

  /// No description provided for @deviceIconLabelCabin.
  ///
  /// In de, this message translates to:
  /// **'Hütte'**
  String get deviceIconLabelCabin;

  /// No description provided for @deviceIconLabelGeneral.
  ///
  /// In de, this message translates to:
  /// **'Allgemein'**
  String get deviceIconLabelGeneral;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
