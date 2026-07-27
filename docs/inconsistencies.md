# Solar WiFi Weather Station – Inconsistencies Analysis

## Overview
Cross-check of **Sketches** (ESP8266/ESP32 Arduino), **API** (PHP/MySQL), and **App** (Flutter/Dart) 
for data model mismatches, naming conflicts, routing issues, and dead code.

---

## 1. MISSING METRIC DEFINITIONS IN API (Sketch sends → API doesn't define labels)

**Files:**
- `sketch_sws/.../v2_6.ino` (line 948-961) – sendToAPI()
- `api/data.php` (line 148-160) – `$knownLabels`

The sketch sends these fields that the API's `$knownLabels` dictionary doesn't define:

| Sketch Field       | Known Label? | Impact |
|--------------------|-------------|--------|
| `dewpoint`         | ❌           | Stored as metric, label = auto-generated ("Dewpoint") |
| `dewpointspread`   | ❌           | Stored as metric, label = auto-generated ("Dewpointspread") |
| `heatindex`        | ❌           | Stored as metric, label = auto-generated ("Heatindex") |
| `fw_version`       | ❌           | Stored as metric, label = auto-generated ("Fw version") |

**Fix:** Add to `$knownLabels` in `api/data.php`:
```php
'dewpoint'       => ['Taupunkt',            '°C'],
'dewpointspread' => ['Taupunktdifferenz',   '°C'],
'heatindex'      => ['Hitzeindex',          '°C'],
'fw_version'     => ['Firmware-Version',    ''],
```

---

## 2. NEUER ORDNER – DEAD COPY OF api/ DIRECTORY

**Location:** `Neuer Ordner/`

The entire `Neuer Ordner/` directory is a byte-for-byte copy of `api/`. 
This is dead code that will diverge over time and must be deleted.

- Duplicates: auth.php, config.php, data.php, helpers.php, history.php, etc.
- Subfolders: config/, homeassistant/, install/, ota/
- **Action:** Remove `Neuer Ordner/` from the repository.

---

## 3. APP CALLS /admin/stations BUT ROUTER HAS /stations (No Admin Prefix)

**Files:**
- `app/lib/services/api_service.dart` (line 109) – `_buildUri(device, 'admin/stations')`
- `api/index.php` (line 50) – `'PATCH /stations'`

The App sends HTTP PATCH to path `admin/stations`.
The router strips `/sws/api` prefix, yielding `/admin/stations`.
But the registered route is `PATCH /stations` (no admin/ prefix).

**Result:** PATCH requests from the App return HTTP 404 ("Unbekannte Route").

**Fix:** Change api_service.dart line 109:
```dart
final uri = _buildUri(device, 'stations');
```

---

## 4. APP MeasurementPoint – INCOMPLETE HISTORY DATA MODEL

**Files:**
- `app/lib/models/measurement.dart` (line 100-147) – `MeasurementPoint`
- `api/history.php` (line 89-95) – history response

`MeasurementPoint.fromJson()` only parses:
`temperature, pool_temperature, rel_pressure, humidity, battery_pct, created_at`

But the history API returns **ALL** metrics including: `abs_pressure`, `pressure_state`, 
`zambretti`, `zambretti_text`, `trend`, `trend_text`, `dewpoint`, `dewpointspread`, 
`heatindex`, and any `extraSensors` the sketch sends.

**Impact:** Historical charts cannot show pressure_state, Zambretti, dewpoint, etc.

---

## 5. PRESSURE STATE NAMING MISMATCH (Sketch vs API vs App)

**Files:**
- `sketch_sws/.../v2_6.ino` (line 348-351) – `pressure_in_words()` → uses `LANG_PRESSURE[]`
- `api/zambretti.php` (line 64-70) – `pressureState()` → hardcoded German strings
- `app/lib/models/measurement.dart` – expects `pressure_state` string

The API's `pressureState()` returns German text labels (e.g., "Sturm", "Hochdruckartig").
The sketch sends a `pressure_idx` (0-4) which maps to `LANG_PRESSURE[]` in the translation file.
The App treats `pressure_state` as an opaque string from the API.

**No mismatch here** – consistent because the API handles the server-side calculation and the App reads whatever string the API returns. But worth noting the sketch-side `pressure_idx` is no longer used (Zambretti is now server-side only).

---

## 6. CONFIG PORTAL – MISSING MAC ADDRESS IN SETTINGS UI

**Files:**
- `sketch_sws/.../v2_6.ino` (line 456-501) – config portal HTML
- `library/SWSApiClient/src/SWSApiClient.cpp` (line 100-106) – `send()` auto-adds device_mac

The config portal form has no field for `device_mac`. The MAC is auto-detected and sent by `SWSApiClient::send()`. This is acceptable (MAC is hardware-derived), but if the user ever needs to override the MAC for multi-station setups, there's no way to do it via the config portal.

---

## 7. API HISTORY ENDPOINT USES JWT – APP USES BASIC AUTH FOR DATA BUT JWT FOR HISTORY

**Files:**
- `app/lib/services/api_service.dart` (line 36-58) – `fetchLatest()` uses Basic Auth
- `app/lib/services/api_service.dart` (line 61-91) – `fetchHistory()` uses Bearer/JWT
- `api/data.php` (line 70) – `requireBasicAuth()`
- `api/history.php` (line 10) – `requireJwt()`

This is **intentional and correct** – public data is Basic-Auth, historical queries require a logged-in user (JWT). No inconsistency.

---

## 8. REMOTE CONFIG PATH – SKETCH USES /sws/api/config, ROUTER HANDLES /config

**Files:**
- `sketch_sws/.../Settings26.h` (line 94) – `CFG_REMOTE_CONFIG_PATH "/sws/api/config"`
- `api/index.php` (line 20-22) – router strips `/sws/api` prefix → yields `/config`
- `api/index.php` (line 54) – `'GET /config' => __DIR__ . '/config.php'`

**Verdict:** Works correctly. The router strips `/sws/api`, then matches `/config` to the `GET /config` route.

---

## 9. SWSAPICLIENT LogPath DERIVATION – NO ".php" EXTENSION

**Files:**
- `library/SWSApiClient/src/SWSApiClient.cpp` (line 219-225) – `_deriveLogPath()`
- `api/index.php` (line 53) – `'POST /log' => __DIR__ . '/log.php'`

`_deriveLogPath()` transforms `/sws/api/data` → `/sws/api/log` (no `.php`).
The router receives `/sws/api/log`, strips prefix → `/log`, matches `POST /log` → `log.php`.

**Verdict:** Works correctly because the router matches without `.php`.

---

## 10. DISPLAY SKETCH – NO API INTEGRATION, NOT REVIEWED

**Files:**
- `sketch_sws_display/sketch_sws_display.ino`

The display sketch has no API integration (no `SWSApiClient`, no `sendToAPI()`).
It was not analyzed for data inconsistencies beyond noting its absence from the API ecosystem.

---

## 11. INDOOR STATION – SENDS UNIQUE METRICS NOT IN API knownLabels

**Files:**
- `sketch_sws_indoor/sketch_sws_indoor.ino` (line 421-433) – `sendToAPI()`
- `api/data.php` (line 148-160) – `$knownLabels`

Indoor sketch sends: `mq_raw`, `mq_avg`, `mq_index`, `mq_trend`, `mq_min`, `mq_max`
None of these are in `$knownLabels`. They are stored dynamically (EAV model) with auto-generated labels.

**Recommendation:** Add MQ135 metric definitions to `$knownLabels`:
```php
'mq_raw'   => ['MQ135 Rohwert',   ''],
'mq_avg'   => ['MQ135 Mittelwert', ''],
'mq_index' => ['MQ135 Index',      '%'],
'mq_trend' => ['MQ135 Trend',      ''],
'mq_min'   => ['MQ135 Minimum',    ''],
'mq_max'   => ['MQ135 Maximum',    ''],
```

---

## 12. Version String – Sketch claims v2.7 but code says v2.6

**Files:**
- `sketch_sws/.../Settings26.h` (line 8) – `const String Version = "2.7.6";`
- `sketch_sws/.../v2_6.ino` (line 15) – header comment says `v2.7 (2025/2026)`
- Directory name: `Solar_WiFi_Weather_Station_v2_6/`

The version string is `2.7.6`, the directory is `v2_6`, and the file header says `V2.7`. Minor but confusing.

---

## Summary of Action Items

| Priority | Issue | File(s) | Action |
|----------|-------|---------|--------|
| 🔴 HIGH | App PATCH admin/stations → 404 | `api_service.dart` + `index.php` | Fix route to `stations` |
| 🟡 MED | Missing knownLabels (sketch fields) | `api/data.php` | Add 4 entries |
| 🟡 MED | Missing knownLabels (indoor MQ fields) | `api/data.php` | Add 6 entries |
| 🟡 MED | `Neuer Ordner/` dead code | repo root | Delete directory |
| 🟢 LOW | MeasurementPoint incomplete fields | `measurement.dart` | Add extra fields |
| 🟢 LOW | Version string / directory naming | `Settings26.h` | Align names |