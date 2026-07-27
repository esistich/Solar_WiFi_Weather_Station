<?php
/**
 * v1/data.php – Messdaten-Endpunkt (dynamische Metriken via EAV)
 *
 * GET  /v1/data?station=<slug>   – letzter Messdatensatz (öffentlich)
 *                                  ohne station= → erste/einzige Station
 * POST /v1/data                  – neuen Messdatensatz speichern (Basic Auth)
 *
 * POST-Body (JSON) – alle Felder außer station_slug sind dynamisch:
 * {
 *   "station_slug": "sws-garten",   // optional, default: erste Station
 *   "device_ts":    1234567890,      // Unix-Timestamp des Geräts (optional)
 *   "temperature":  21.5,
 *   "humidity":     55.2,
 *   "rel_pressure": 1013.4,
 *   ...beliebig weitere Metriken...
 * }
 */

declare(strict_types=1);

require_once __DIR__ . '/zambretti.php';

$db = getDb();

// ── GET: letzter Messdatensatz ────────────────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
	$slug    = $_GET['station'] ?? null;
	$station = resolveStation($db, $slug);
	if (!$station) {
		logSystemEvent('warning', 'station', 'UNKNOWN_STATION_GET', "Unbekannte Station '$slug' via GET /data", [
			'slug' => $slug ?? '(kein)',
		]);
		sendJson(404, ['error' => 'Station nicht gefunden']);
	}

	// Letzte Messung
	$meas = $db->prepare('
		SELECT id, created_at, device_ts
		FROM   measurements
		WHERE  station_id = ?
		ORDER  BY created_at DESC
		LIMIT  1
	');
	$meas->execute([$station['id']]);
	$row = $meas->fetch();

	if (!$row) {
		sendJson(200, ['station' => $station['slug'], 'data' => null]);
	}

	// created_at liegt in UTC – fuer Ausgabe in Europe/Berlin konvertieren
	$utcDt   = new DateTimeImmutable($row['created_at'], new DateTimeZone('UTC'));
	$localDt = $utcDt->setTimezone(new DateTimeZone('Europe/Berlin'));
	$row['created_at'] = $localDt->format('Y-m-d H:i:s');
	// data_age_s immer gegen UTC berechnen (time() ist UTC)
	$ageS = max(0, (int)(time() - $utcDt->getTimestamp()));

	$values = loadValues($db, $row['id']);

	sendJson(200, array_merge(
		['station' => $station['slug'], 'station_name' => $station['name']],
		$values,
		['created_at' => $row['created_at'], 'data_age_s' => $ageS]
	));
}

// ── POST: Messdaten speichern ─────────────────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
	requireBasicAuth();

	// Shim hat den Body bereits gelesen und uebersetzt – Global bevorzugen
	$raw  = $GLOBALS['_shimBody'] ?? json_decode(file_get_contents('php://input'), true);
	$body = is_array($raw) ? $raw : null;

	if (!$body) {
		logSystemEvent('warning', 'api', 'INVALID_JSON', 'POST /data mit ungültigem JSON-Body', [
			'content_type' => $_SERVER['CONTENT_TYPE'] ?? '(kein)',
		]);
		sendJson(400, ['error' => 'Ungültiger JSON-Body']);
	}

	// Station bestimmen oder anlegen
	$mac     = normalizeMac($body['device_mac'] ?? null);
	$slug    = $body['station_slug'] ?? null;
	$station = resolveStation($db, $slug, $mac);

	if (!$station) {
		if ($mac) {
			// Neue Station per MAC automatisch anlegen
			$autoSlug = 'sws-' . str_replace(':', '', substr($mac, -6));
			$name     = $body['station_name'] ?? ('SWS ' . strtoupper(substr($autoSlug, 4)));
			$db->prepare('INSERT INTO stations (slug, name, mac) VALUES (?, ?, ?)')
			   ->execute([$autoSlug, $name, $mac]);
			$station = ['id' => (int)$db->lastInsertId(), 'slug' => $autoSlug, 'name' => $name, 'mac' => $mac];

			logSystemEvent('info', 'station', 'STATION_AUTO_CREATED', "Neue Station '$autoSlug' per MAC $mac automatisch angelegt", [
				'mac' => $mac,
				'slug' => $autoSlug,
			]);
		} elseif ($slug) {
			logSystemEvent('warning', 'station', 'UNKNOWN_STATION', "Unbekannte Station '$slug' versuchte Daten zu senden", [
				'slug' => $slug,
				'body_keys' => array_keys($body),
			]);
			sendJson(404, ['error' => "Station '$slug' nicht gefunden"]);
		} else {
			logSystemEvent('warning', 'station', 'NO_STATION_ID', 'POST /data ohne device_mac oder station_slug', [
				'body_keys' => array_keys($body),
			]);
			sendJson(400, ['error' => 'device_mac oder station_slug erforderlich']);
		}
	}

	$deviceTs = isset($body['device_ts']) ? (int)$body['device_ts'] : null;

	// Messung anlegen
	try {
		$stmt = $db->prepare('INSERT INTO measurements (station_id, device_ts) VALUES (?, FROM_UNIXTIME(?))');
		$stmt->execute([$station['id'], $deviceTs]);
		$measId = (int)$db->lastInsertId();
	} catch (\Throwable $e) {
		logSystemEvent('error', 'db', 'DB_INSERT_FAILED', 'Messung konnte nicht gespeichert werden: ' . $e->getMessage(), [
			'station_id' => $station['id'],
			'station' => $station['slug'],
		]);
		sendJson(500, ['error' => 'Datenbankfehler beim Speichern']);
	}

	// Reservierte Keys die keine Metriken sind, plus Felder die die API jetzt selbst berechnet
	$skip = [
		'station_slug', 'station_name', 'device_ts', 'device_mac',
		// Folgende Felder wurden frueher vom Sketch gesendet, werden jetzt
		// von calculateAndStoreZambretti() in der API berechnet:
		'zambrettisays', 'zletter', 'trendinwords', 'accuracy',
		'pressurestate', 'pressure_state',
	];

	// Alle übrigen Felder als Metriken speichern
	$stmtVal  = $db->prepare('INSERT INTO measurement_values (measurement_id, metric_key, value) VALUES (?, ?, ?)');
	$stmtMeta = $db->prepare('
		INSERT INTO metric_definitions (metric_key, label, unit, display_order)
		VALUES (?, ?, ?, 99)
		ON DUPLICATE KEY UPDATE metric_key = metric_key
	');

	// Standard-Labels für bekannte Metriken
	$knownLabels = [
		'temperature'    => ['Temperatur Außen',  '°C'],
		'pool_temperature'=> ['Temperatur Wasser', '°C'],
		'humidity'       => ['Luftfeuchte',        '%'],
		'rel_pressure'   => ['Luftdruck (rel.)',   'hPa'],
		'abs_pressure'   => ['Luftdruck (abs.)',   'hPa'],
		'pressure_state' => ['Drucktrend',         ''],
		'zambretti'      => ['Zambretti',          ''],
		'trend'          => ['Drucktrend num.',    ''],
		'battery_pct'    => ['Batterie',           '%'],
		'battery_volt'   => ['Spannung',           'V'],
		'wifi_strength'  => ['WLAN',               'dBm'],
		'dewpoint'       => ['Taupunkt',            '°C'],
		'dewpointspread' => ['Taupunktdifferenz',   '°C'],
		'heatindex'      => ['Hitzeindex',          '°C'],
		'fw_version'     => ['Firmware-Version',    ''],
		'mq_raw'         => ['MQ135 Rohwert',       ''],
		'mq_avg'         => ['MQ135 Mittelwert',    ''],
		'mq_index'       => ['MQ135 Index',         '%'],
		'mq_trend'       => ['MQ135 Trend',         ''],
		'mq_min'         => ['MQ135 Minimum',       ''],
		'mq_max'         => ['MQ135 Maximum',       ''],
	];

	$errors = [];
	foreach ($body as $key => $val) {
		if (in_array($key, $skip, true)) continue;
		if (!is_numeric($val) && !is_string($val)) continue;

		[$label, $unit] = $knownLabels[$key] ?? [ucfirst(str_replace('_', ' ', $key)), ''];
		try {
			$stmtMeta->execute([$key, $label, $unit]);
		} catch (Throwable $e) {
			$errors[] = "meta[$key]: " . $e->getMessage();
			logSystemEvent('error', 'db', 'DB_META_FAILED', "Metrik-Definition '$key' konnte nicht gespeichert werden", [
				'error' => $e->getMessage(),
				'station' => $station['slug'],
			]);
		}
		try {
			$stmtVal->execute([$measId, $key, is_numeric($val) ? (string)(float)$val : (string)$val]);
		} catch (Throwable $e) {
			$errors[] = "val[$key]: " . $e->getMessage();
			logSystemEvent('error', 'db', 'DB_VAL_FAILED', "Messwert '$key' konnte nicht gespeichert werden", [
				'error' => $e->getMessage(),
				'station' => $station['slug'],
			]);
		}
	}

	// Zambretti-Vorhersage server-seitig berechnen und in measurement_values schreiben
	$deviceTsForZambretti = $deviceTs ?? time();
	try {
		calculateAndStoreZambretti($db, (int)$station['id'], $measId, $deviceTsForZambretti);
	} catch (Throwable $e) {
		$errors[] = 'zambretti: ' . $e->getMessage();
	}

	sendJson(200, ['ok' => true, 'measurement_id' => $measId, 'station' => $station['slug'], 'errors' => $errors]);
}

sendJson(405, ['error' => 'Methode nicht erlaubt']);

// ── Hilfsfunktionen ───────────────────────────────────────────────────────────

// resolveStation() ist in v1/helpers.php definiert

function loadValues(PDO $db, int $measId): array
{
	$stmt = $db->prepare('
		SELECT mv.metric_key, mv.value, md.unit
		FROM   measurement_values mv
		LEFT   JOIN metric_definitions md ON md.metric_key = mv.metric_key
		WHERE  mv.measurement_id = ?
	');
	$stmt->execute([$measId]);
	$result = [];
	foreach ($stmt->fetchAll() as $row) {
		$result[$row['metric_key']] = is_numeric($row['value']) ? round((float)$row['value'], 4) : $row['value'];
	}
	return $result;
}
