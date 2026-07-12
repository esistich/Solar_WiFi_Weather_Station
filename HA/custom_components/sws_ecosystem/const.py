from __future__ import annotations

from datetime import timedelta
from typing import Final

from homeassistant.components.sensor import SensorDeviceClass, SensorStateClass

DOMAIN: Final = "sws_ecosystem"
CONF_SLUG: Final = "slug"
API_BASE_URL: Final = "https://timm-sander.net/sws/api/data"
DEFAULT_SCAN_INTERVAL: Final = timedelta(seconds=60)
MANUFACTURER: Final = "Solar WiFi Weather Station Ecosystem"

SENSOR_DEFINITIONS: Final = (
    {
        "key": "timestamp",
        "name": "Timestamp",
        "icon": "mdi:clock-outline",
        "device_class": SensorDeviceClass.TIMESTAMP,
        "unit": None,
        "state_class": None,
    },
    {
        "key": "temperature",
        "name": "Temperature",
        "icon": "mdi:thermometer",
        "device_class": SensorDeviceClass.TEMPERATURE,
        "unit": "°C",
        "state_class": SensorStateClass.MEASUREMENT,
    },
    {
        "key": "humidity",
        "name": "Humidity",
        "icon": "mdi:water-percent",
        "device_class": SensorDeviceClass.HUMIDITY,
        "unit": "%",
        "state_class": SensorStateClass.MEASUREMENT,
    },
    {
        "key": "dewpoint",
        "name": "Dewpoint",
        "icon": "mdi:water",
        "device_class": SensorDeviceClass.TEMPERATURE,
        "unit": "°C",
        "state_class": SensorStateClass.MEASUREMENT,
    },
    {
        "key": "dewpointspread",
        "name": "Dewpoint Spread",
        "icon": "mdi:thermometer-chevron-up",
        "device_class": SensorDeviceClass.TEMPERATURE,
        "unit": "°C",
        "state_class": SensorStateClass.MEASUREMENT,
    },
    {
        "key": "heatindex",
        "name": "Heat Index",
        "icon": "mdi:thermometer-alert",
        "device_class": SensorDeviceClass.TEMPERATURE,
        "unit": "°C",
        "state_class": SensorStateClass.MEASUREMENT,
    },
    {
        "key": "pool_temperature",
        "name": "Pool Temperature",
        "icon": "mdi:pool-thermometer",
        "device_class": SensorDeviceClass.TEMPERATURE,
        "unit": "°C",
        "state_class": SensorStateClass.MEASUREMENT,
    },
    {
        "key": "abs_pressure",
        "name": "Absolute Pressure",
        "icon": "mdi:gauge",
        "device_class": SensorDeviceClass.PRESSURE,
        "unit": "hPa",
        "state_class": SensorStateClass.MEASUREMENT,
    },
    {
        "key": "rel_pressure",
        "name": "Relative Pressure",
        "icon": "mdi:gauge",
        "device_class": SensorDeviceClass.PRESSURE,
        "unit": "hPa",
        "state_class": SensorStateClass.MEASUREMENT,
    },
    {
        "key": "pressure_state",
        "name": "Pressure State",
        "icon": "mdi:information-outline",
        "device_class": None,
        "unit": None,
        "state_class": None,
    },
    {
        "key": "trend",
        "name": "Trend",
        "icon": "mdi:trending-up",
        "device_class": None,
        "unit": None,
        "state_class": None,
    },
    {
        "key": "trend_raw",
        "name": "Trend Raw",
        "icon": "mdi:chart-bell-curve",
        "device_class": None,
        "unit": None,
        "state_class": SensorStateClass.MEASUREMENT,
    },
    {
        "key": "trend_text",
        "name": "Trend Text",
        "icon": "mdi:text-box-outline",
        "device_class": None,
        "unit": None,
        "state_class": None,
    },
    {
        "key": "zambretti",
        "name": "Zambretti",
        "icon": "mdi:weather-partly-cloudy",
        "device_class": None,
        "unit": None,
        "state_class": SensorStateClass.MEASUREMENT,
    },
    {
        "key": "zambretti_text",
        "name": "Zambretti Text",
        "icon": "mdi:weather-cloudy",
        "device_class": None,
        "unit": None,
        "state_class": None,
    },
    {
        "key": "battery_pct",
        "name": "Battery Percent",
        "icon": "mdi:battery",
        "device_class": SensorDeviceClass.BATTERY,
        "unit": "%",
        "state_class": SensorStateClass.MEASUREMENT,
    },
    {
        "key": "battery_volt",
        "name": "Battery Voltage",
        "icon": "mdi:flash",
        "device_class": SensorDeviceClass.VOLTAGE,
        "unit": "V",
        "state_class": SensorStateClass.MEASUREMENT,
    },
    {
        "key": "accuracy_pct",
        "name": "Accuracy Percent",
        "icon": "mdi:target",
        "device_class": None,
        "unit": "%",
        "state_class": SensorStateClass.MEASUREMENT,
    },
    {
        "key": "wifi_strength",
        "name": "WiFi Strength",
        "icon": "mdi:wifi",
        "device_class": SensorDeviceClass.SIGNAL_STRENGTH,
        "unit": "dBm",
        "state_class": SensorStateClass.MEASUREMENT,
    },
    {
        "key": "fw_version",
        "name": "Firmware Version",
        "icon": "mdi:chip",
        "device_class": None,
        "unit": None,
        "state_class": None,
    },
)
