from __future__ import annotations

from typing import Any
import logging

from homeassistant.config_entries import ConfigEntry
from homeassistant.const import Platform
from homeassistant.core import HomeAssistant
from homeassistant.helpers.aiohttp_client import async_get_clientsession
from homeassistant.helpers.update_coordinator import DataUpdateCoordinator, UpdateFailed

from .const import API_BASE_URL, CONF_SLUG, DEFAULT_SCAN_INTERVAL, DOMAIN

_LOGGER = logging.getLogger(__name__)
PLATFORMS: list[Platform] = [Platform.SENSOR]


class SWSDataUpdateCoordinator(DataUpdateCoordinator[dict[str, Any]]):
    """Fetch and normalize weather data for one station slug."""

    def __init__(self, hass: HomeAssistant, slug: str) -> None:
        self.slug = slug
        super().__init__(
            hass,
            _LOGGER,
            name=f"{DOMAIN}_{slug}",
            update_interval=DEFAULT_SCAN_INTERVAL,
        )

    async def _async_update_data(self) -> dict[str, Any]:
        session = async_get_clientsession(self.hass)
        url = f"{API_BASE_URL}?station={self.slug}"

        try:
            response = await session.get(url, timeout=10)
            response.raise_for_status()
            payload = await response.json(content_type=None)
        except Exception as err:
            raise UpdateFailed(f"Unable to fetch SWS data for {self.slug}: {err}") from err

        if not isinstance(payload, dict):
            raise UpdateFailed(f"Unexpected payload type for {self.slug}: {type(payload)!r}")

        return _normalize_payload(payload)


async def async_setup(hass: HomeAssistant, config: dict[str, Any]) -> bool:
    hass.data.setdefault(DOMAIN, {})
    return True


async def async_setup_entry(hass: HomeAssistant, entry: ConfigEntry) -> bool:
    coordinator = SWSDataUpdateCoordinator(hass, entry.data[CONF_SLUG])
    await coordinator.async_config_entry_first_refresh()

    hass.data.setdefault(DOMAIN, {})[entry.entry_id] = {
        "coordinator": coordinator,
        "slug": entry.data[CONF_SLUG],
    }

    await hass.config_entries.async_forward_entry_setups(entry, PLATFORMS)
    return True


async def async_unload_entry(hass: HomeAssistant, entry: ConfigEntry) -> bool:
    unload_ok = await hass.config_entries.async_unload_platforms(entry, PLATFORMS)
    if unload_ok:
        hass.data[DOMAIN].pop(entry.entry_id, None)
        if not hass.data[DOMAIN]:
            hass.data.pop(DOMAIN)
    return unload_ok


def _normalize_payload(payload: dict[str, Any]) -> dict[str, Any]:
    normalized: dict[str, Any] = {}

    for key, value in payload.items():
        normalized[key] = value

    normalized["timestamp"] = (
        payload.get("timestamp")
        or payload.get("datetime")
        or payload.get("created_at")
        or payload.get("time")
    )
    normalized["dewpointspread"] = payload.get("dewpointspread", payload.get("dewpoint_spread"))
    normalized["heatindex"] = payload.get("heatindex", payload.get("heat_index"))
    normalized["trend_raw"] = payload.get("trend_raw", payload.get("trend_value"))
    normalized["trend_text"] = payload.get("trend_text") or payload.get("trend")
    normalized["zambretti"] = payload.get("zambretti")
    normalized["zambretti_text"] = payload.get("zambretti_text") or payload.get("zambretti")
    normalized["accuracy_pct"] = payload.get("accuracy_pct", payload.get("accuracy"))
    normalized["fw_version"] = payload.get("fw_version")

    return normalized
