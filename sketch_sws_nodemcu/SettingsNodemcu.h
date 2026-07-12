/*----------------------------------------------------------------------------------------------------
  Project Name : Solar Powered WiFi Weather Station – NodeMCU V3 Edition
  Board       : NodeMCU V3 (ESP8266 12F)
  Features    : temperature, dewpoint, humidity, pressure, Zambretti (API), battery status
  Authors     : Keith Hungerford, Debasish Dutta, Marc Stähli
  Website     : www.opengreenenergy.com
----------------------------------------------------------------------------------------------------*/

const String Version = "3.0.0";

// =====================================================================
// Compile-Zeit-Fallbacks – werden beim ersten Start oder nach Werksreset
// verwendet. Laufende Werte kommen aus dem EEPROM (Config-Portal).
// =====================================================================

/****** Konfigurations-Portal ************************************************/
// GPIO12 = D6 (boot-neutral, nicht GPIO0/D3!)
#define CONFIG_BUTTON_PIN   12
#define CONFIG_AP_SSID      "SWS-Config"

/******* Language Selection **************************************************/
#include "Translations/Translation_DE.h"

#define PRESS_STORM_LOW   0
#define PRESS_STRONG_LOW  1
#define PRESS_LOW         2
#define PRESS_HIGH        3
#define PRESS_STRONG_HIGH 4

/******* Sensor Configuration ************************************************/
#define USE_DS18B20    1     // DS18B20 Zusatzfuehler (One-Wire, D7/GPIO13)

/****** WiFi Settings (Compile-Zeit-Fallbacks) ******************************/
#define CFG_DEFAULT_STATION_NAME  "SWS_NodeMCU"
#define CFG_DEFAULT_WIFI_SSID     "YOUR_SSID"
#define CFG_DEFAULT_WIFI_PASS     "YOUR_PASSWORD"

/****** REST-API Settings ****************************************************/
#define USE_API 1

#define CFG_DEFAULT_API_ENABLED   true
#define CFG_DEFAULT_API_HTTPS     true
#define CFG_DEFAULT_API_HOST      "timm-sander.net"
#define CFG_DEFAULT_API_PATH      "/sws/api/data"
#define CFG_DEFAULT_API_PORT      443
#define CFG_DEFAULT_API_USER      "NAy1b4GpuS3dEvej"
#define CFG_DEFAULT_API_PASS      "REDACTED_API_PASS"

/****** Remote-Config ********************************************************/
#define USE_REMOTE_CONFIG         1
#define CFG_REMOTE_CONFIG_PATH    "/sws/api/config"
#define CFG_REMOTE_CONFIG_TIMEOUT 5000

/****** OTA-Update ***********************************************************/
#define USE_OTA                  1
#define CFG_OTA_BASE_PATH         "/sws/api/ota/firmware"
#define CFG_OTA_SKETCH_ID         "sws_nodemcu"
#define CFG_OTA_TIMEOUT_MS        5000

/****** Additional Settings (Compile-Zeit-Fallbacks) ************************/

#define BATTERY_CALIB_FACTOR  5.2f      // Spannungsteiler-Kalibrierung (R1=540k, R2=100k)

#define CFG_DEFAULT_TEMP_CORR     0.0f   // Temperaturkorrektur in °C
#define CFG_DEFAULT_ELEVATION     420    // Höhe über NN in Metern
#define CFG_DEFAULT_SLEEP_MIN     10     // Deep-Sleep-Dauer in Minuten
#define NTP_SERVER "ch.pool.ntp.org"

#define WINTER_THRESHOLD_LOW   (1.5)
#define WINTER_THRESHOLD_HIGH  (2.5)

/****** Deep Sleep ***********************************************************/
// NodeMCU: D0 (GPIO16) mit RST verbinden fuer Deep-Sleep-Wakeup
#define DEEP_SLEEP_WAKE_PIN       16
