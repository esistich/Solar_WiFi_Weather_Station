# SWS Companion App – Flutter

Eine moderne Android-App (Flutter) zur Echtzeit-Überwachung und Konfiguration deiner Solar WiFi Weather Stations (SWS).

## Features

- **Dashboard**: Übersicht über alle Stationen mit dynamischen Hintergründen (Material 3 Dynamic Color).
- **Detailansicht**: Interaktive History-Charts (Temperatur, Luftfeuchte, Druck, Akku) für verschiedene Zeiträume (6h, 24h, 7d).
- **Immersives Design**: Volle Edge-to-Edge Unterstützung für Android 15+.
- **Automatisches Setup**: Integrierter Soft-AP Flow zum einfachen Verbinden neuer Stationen mit deinem WLAN.
- **Benachrichtigungen**: Intelligente Frost- und Akkuwarnungen im Hintergrund.
- **Widgets**: Unterstützung für Android Homescreen-Widgets zur schnellen Statusprüfung.

## Voraussetzungen

- Flutter SDK ≥ 3.32
- Android Studio oder VS Code
- Ein konfiguriertes SWS-Backend (PHP/Node.js)

## Erste Schritte

1. **Abhängigkeiten installieren**:
   ```bash
   flutter pub get
   ```

2. **Lokalisierung generieren**:
   Die App nutzt das offizielle Flutter Localization System, generiert jedoch die Dateien lokal im Projekt für maximale Kompatibilität. Führe den folgenden Befehl aus, um die Sprachdateien zu generieren:
   ```bash
   flutter gen-l10n
   ```
   Dies erstellt die Dateien im Verzeichnis `lib/l10n/generated/`.

3. **Firebase Konfiguration**:
   Registriere deine App in der Firebase Console (Package: `net.timm_sander.sws`) und platziere die `google-services.json` in `android/app/`.

4. **App starten**:
   ```bash
   flutter run
   ```

## Architektur

Die App folgt einer sauberen Architektur mit klarer Trennung von Belangen:

- **Services**: Kapseln die externe Kommunikation (API, Auth, Push, Alarme).
- **Models**: Definieren die Datenstrukturen (Device, Measurement).
- **Provider**: Verwalten den globalen App-Zustand (State Management via `provider`).
- **UI (Screens/Widgets)**: Deklarative Benutzeroberfläche mit Jetpack Compose-ähnlichem Aufbau in Flutter.

## Lokalisierung (l10n)

Alle Texte der App sind zentralisiert. Um neue Texte hinzuzufügen oder bestehende zu ändern:
1. Bearbeite `lib/l10n/app_de.arb`.
2. Führe `flutter gen-l10n` aus.
3. Greife im Code via `AppLocalizations.of(context)!` auf die Texte zu.

## Lizenz

Dieses Projekt steht unter der **MIT-Lizenz**. Siehe [LICENSE](LICENSE) für Details.
