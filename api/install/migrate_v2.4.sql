-- ----------------------------------------------------------
-- Migration v2.4 – system_log Tabelle für API-Level-Logging
-- Loggt: Auth-Fehler, unbekannte Stationen, DB-Fehler, 404-Routen
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `system_log` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `level`      ENUM('error','warning','info') NOT NULL DEFAULT 'error'
                 COMMENT 'Schweregrad: error = kritisch, warning = Warnung, info = Information',
  `source`     VARCHAR(32)     NOT NULL DEFAULT 'api'
                 COMMENT 'Quelle: api, auth, db, station, router',
  `code`       VARCHAR(64)     NOT NULL
                 COMMENT 'Maschinenlesbarer Kurzcode, z.B. AUTH_FAILED, UNKNOWN_STATION, DB_ERROR, ROUTE_404',
  `message`    VARCHAR(512)    NOT NULL DEFAULT ''
                 COMMENT 'Menschenlesbare Beschreibung',
  `context`    JSON            NULL
                 COMMENT 'Zusatzdaten als JSON (z.B. IP, URI, Request-Body)',
  `ip`         VARCHAR(45)     NULL
                 COMMENT 'Client-IP-Adresse',
  `created_at` TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_level_created` (`level`, `created_at`),
  KEY `idx_source_created` (`source`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='API- und System-Ereignisse (Auth-Fehler, unbekannte Stationen, DB-Probleme, etc.)';
