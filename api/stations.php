<?php
/**
 * SWS Stations – Station auflisten & bearbeiten
 *
 * GET   /stations         – Stationsliste (öffentlich)
 * PATCH /stations         – Station umbenennen (JWT Bearer)
 *   Body: {"slug":"<aktuell>","name":"<neu>","new_slug":"<neu>"}
 */
declare(strict_types=1);

$db     = getDb();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

// ── GET: Stationsliste ──────────────────────────────────────────────
if ($method === 'GET') {
	$rows = $db->query('SELECT id, slug, name, created_at FROM stations ORDER BY id')->fetchAll();
	sendJson(200, ['stations' => $rows]);
}

// ── PATCH: Station umbenennen (JWT, für Flutter-App) ────────────────
if ($method === 'PATCH') {
	$payload = requireJwt();

	$raw  = file_get_contents('php://input');
	$body = json_decode($raw ?: '{}', true) ?? [];

	$currentSlug = trim($body['slug'] ?? '');
	$newName     = trim($body['name'] ?? '');
	$newSlug     = trim($body['new_slug'] ?? '');

	if (!$currentSlug || !$newName || !$newSlug) sendJson(400, ['error' => 'Daten unvollständig (slug/name/new_slug erforderlich)']);
	if (!preg_match('/^[a-z0-9\-]+$/', $newSlug)) sendJson(422, ['error' => 'Slug darf nur Kleinbuchstaben, Zahlen und Bindestriche enthalten']);

	$stmt = $db->prepare('SELECT id, slug, name FROM stations WHERE slug = ? LIMIT 1');
	$stmt->execute([$currentSlug]);
	$station = $stmt->fetch();
	if (!$station) sendJson(404, ['error' => "Station '$currentSlug' nicht gefunden"]);

	if ($newSlug !== $station['slug']) {
		$check = $db->prepare('SELECT id FROM stations WHERE slug = ? AND id != ? LIMIT 1');
		$check->execute([$newSlug, $station['id']]);
		if ($check->fetch()) sendJson(409, ['error' => "Slug '$newSlug' bereits vergeben"]);
	}

	$db->prepare('UPDATE stations SET name = ?, slug = ? WHERE id = ?')->execute([$newName, $newSlug, $station['id']]);
	sendJson(200, ['station' => ['id' => $station['id'], 'slug' => $newSlug, 'name' => $newName]]);
}

sendJson(405, ['error' => 'Methode nicht erlaubt']);
