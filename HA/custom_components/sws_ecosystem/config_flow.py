from __future__ import annotations

import logging
from typing import Any

import voluptuous as vol

from homeassistant import config_entries
from homeassistant.core import HomeAssistant
from homeassistant.helpers import config_validation as cv
from homeassistant.helpers.aiohttp_client import async_get_clientsession

from .const import CONF_SLUG, DOMAIN

_LOGGER = logging.getLogger(__name__)


class SWSConfigFlow(config_entries.ConfigFlow, domain=DOMAIN):
    VERSION = 1

    async def async_step_user(self, user_input: dict[str, Any] | None = None):
        errors: dict[str, str] = {}

        if user_input is not None:
            slug = user_input[CONF_SLUG].strip().lower()
            if not slug:
                errors["base"] = "invalid_slug"
            else:
                await self.async_set_unique_id(f"station_{slug}")
                self._abort_if_unique_id_configured()

                session = async_get_clientsession(self.hass)
                try:
                    response = await session.get(
                        f"https://timm-sander.net/sws/api/data?station={slug}", timeout=10
                    )
                    response.raise_for_status()
                    payload = await response.json(content_type=None)
                except Exception as err:
                    _LOGGER.warning("Initial API validation failed for slug %s: %s", slug, err)
                    errors["base"] = "cannot_connect"
                else:
                    if not isinstance(payload, dict):
                        errors["base"] = "cannot_connect"
                    else:
                        return self.async_create_entry(
                            title=f"SWS {slug}",
                            data={CONF_SLUG: slug},
                        )

        return self.async_show_form(
            step_id="user",
            data_schema=vol.Schema(
                {
                    vol.Required(CONF_SLUG, default=(user_input or {}).get(CONF_SLUG, "")): cv.string,
                }
            ),
            errors=errors,
        )
