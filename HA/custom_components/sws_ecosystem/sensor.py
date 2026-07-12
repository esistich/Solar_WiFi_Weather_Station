from __future__ import annotations

import logging
from typing import Any

from homeassistant.components.sensor import SensorEntity
from homeassistant.config_entries import ConfigEntry
from homeassistant.core import HomeAssistant
from homeassistant.helpers.entity import DeviceInfo
from homeassistant.helpers.entity_platform import AddEntitiesCallback
from homeassistant.helpers.update_coordinator import CoordinatorEntity

from .const import CONF_SLUG, DOMAIN, MANUFACTURER, SENSOR_DEFINITIONS

_LOGGER = logging.getLogger(__name__)


async def async_setup_entry(
    hass: HomeAssistant,
    entry: ConfigEntry,
    async_add_entities: AddEntitiesCallback,
) -> None:
    coordinator = hass.data[DOMAIN][entry.entry_id]["coordinator"]
    slug = entry.data[CONF_SLUG]
    entities: list[SWSCoordinatorSensor] = []

    for definition in SENSOR_DEFINITIONS:
        entities.append(SWSCoordinatorSensor(coordinator, entry, slug, definition))

    async_add_entities(entities)


class SWSCoordinatorSensor(CoordinatorEntity, SensorEntity):
    _attr_has_entity_name = True

    def __init__(
        self,
        coordinator,
        entry: ConfigEntry,
        slug: str,
        definition: dict[str, Any],
    ) -> None:
        super().__init__(coordinator)
        self._entry = entry
        self._slug = slug
        self._definition = definition
        self._attr_unique_id = f"{slug}_{definition['key']}"
        self._attr_name = definition["name"]
        self._attr_icon = definition["icon"]
        self._attr_device_class = definition["device_class"]
        self._attr_native_unit_of_measurement = definition["unit"]
        self._attr_state_class = definition["state_class"]
        self._attr_entity_category = None

    @property
    def device_info(self) -> DeviceInfo:
        return DeviceInfo(
            identifiers={(DOMAIN, self._slug)},
            name=f"SWS {self._slug}",
            manufacturer=MANUFACTURER,
            model="Weather Station",
            configuration_url="https://timm-sander.net/sws/api/data?station=" + self._slug,
        )

    @property
    def native_value(self):
        value = self.coordinator.data.get(self._definition["key"])

        if value is None:
            return None

        numeric_keys = {
            "temperature",
            "humidity",
            "dewpoint",
            "dewpointspread",
            "heatindex",
            "pool_temperature",
            "abs_pressure",
            "rel_pressure",
            "trend_raw",
            "accuracy_pct",
            "battery_pct",
            "battery_volt",
            "wifi_strength",
        }

        if self._definition["key"] in numeric_keys:
            try:
                return float(value)
            except (TypeError, ValueError):
                return None

        return value
