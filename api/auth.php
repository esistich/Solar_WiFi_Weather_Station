<?php
/**
 * SWS Auth – Login, Register, Logout, Push, Invite
 * Wird vom Router für /auth/* und /push/* und /invite/* aufgerufen.
 */
declare(strict_types=1);

$db  = getDb();
$uri = '/' . trim(preg_replace('#^.*?/sws/api#', '', parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH)), '/');
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

// ── POST /auth/login ────────────────────────────────────────────────
if ($uri === 'auth/login' && $method === 'POST') {
	$raw  = file_get_contents('php://input');
	$body = json_decode($raw ?: '{}', true) ?? [];
	$email = trim($body['email'] ?? '');
	$pass  = trim($body['password'] ?? '');
	if (!$email || !$pass) sendJson(400, ['error' => 'email und password erforderlich']);

	$stmt = $db->prepare('SELECT id, email, password FROM users WHERE email = ? LIMIT 1');
	$stmt->execute([$email]);
	$user = $stmt->fetch();
	if (!$user || !password_verify($pass, $user['password'])) sendJson(401, ['error' => 'Ungültige Anmeldedaten']);

	sendJson(200, ['id' => (string)$user['id'], 'email' => $user['email'], 'token' => jwtEncode(['sub' => $user['id'], 'email' => $user['email']])]);
}

// ── POST /auth/register ─────────────────────────────────────────────
if ($uri === 'auth/register' && $method === 'POST') {
	$body = json_decode(file_get_contents('php://input'), true) ?? [];
	$email  = trim($body['email'] ?? '');
	$pass   = trim($body['password'] ?? '');
	$invite = trim($body['invite_code'] ?? '');
	if (!$email || !$pass || !$invite) sendJson(400, ['error' => 'email, password und invite_code erforderlich']);
	if (!filter_var($email, FILTER_VALIDATE_EMAIL)) sendJson(400, ['error' => 'Ungültige E-Mail-Adresse']);
	if (strlen($pass) < 8) sendJson(400, ['error' => 'Passwort muss mindestens 8 Zeichen haben']);

	$inv = $db->prepare('SELECT id FROM invite_codes WHERE code = ? AND used_at IS NULL LIMIT 1');
	$inv->execute([$invite]);
	$invRow = $inv->fetch();
	if (!$invRow) sendJson(403, ['error' => 'Ungültiger oder bereits verwendeter Einladungscode']);

	$dup = $db->prepare('SELECT id FROM users WHERE email = ? LIMIT 1');
	$dup->execute([$email]);
	if ($dup->fetch()) sendJson(409, ['error' => 'E-Mail bereits registriert']);

	$db->prepare('INSERT INTO users (email, password) VALUES (?, ?)')->execute([$email, password_hash($pass, PASSWORD_BCRYPT)]);
	$userId = (int)$db->lastInsertId();
	$db->prepare('UPDATE invite_codes SET used_at = NOW(), used_by = ? WHERE id = ?')->execute([$userId, $invRow['id']]);

	sendJson(200, ['id' => (string)$userId, 'email' => $email, 'token' => jwtEncode(['sub' => $userId, 'email' => $email])]);
}

// ── POST /auth/logout ───────────────────────────────────────────────
if ($uri === 'auth/logout' && $method === 'POST') {
	requireJwt();
	sendJson(200, ['ok' => true]);
}

// ── POST /push/register ─────────────────────────────────────────────
if ($uri === 'push/register' && $method === 'POST') {
	$payload = requireJwt();
	$body    = json_decode(file_get_contents('php://input'), true) ?? [];
	$token   = trim($body['token'] ?? '');
	if (!$token) sendJson(400, ['error' => 'token erforderlich']);

	$db->prepare('INSERT INTO push_tokens (user_id, token) VALUES (?, ?) ON DUPLICATE KEY UPDATE token = VALUES(token), updated_at = NOW()')
	   ->execute([(int)$payload['sub'], $token]);
	sendJson(200, ['ok' => true]);
}

// ── POST /push/unregister ───────────────────────────────────────────
if ($uri === 'push/unregister' && $method === 'POST') {
	$payload = requireJwt();
	$body    = json_decode(file_get_contents('php://input'), true) ?? [];
	$token   = trim($body['token'] ?? '');
	$db->prepare($token ? 'DELETE FROM push_tokens WHERE user_id = ? AND token = ?' : 'DELETE FROM push_tokens WHERE user_id = ?')
	   ->execute($token ? [(int)$payload['sub'], $token] : [(int)$payload['sub']]);
	sendJson(200, ['ok' => true]);
}

// ── POST /invite/create ─────────────────────────────────────────────
if ($uri === 'invite/create' && $method === 'POST') {
	if (empty($_SESSION['admin'])) { http_response_code(403); echo json_encode(['error' => 'Admin erforderlich']); exit; }
	$code = bin2hex(random_bytes(5));
	$db->prepare('INSERT INTO invite_codes (code) VALUES (?)')->execute([$code]);
	sendJson(201, ['code' => $code]);
}

// ── GET /invite/list ────────────────────────────────────────────────
if ($uri === 'invite/list' && $method === 'GET') {
	if (empty($_SESSION['admin'])) { http_response_code(403); echo json_encode(['error' => 'Admin erforderlich']); exit; }
	sendJson(200, $db->query('SELECT id, code, created_at, used_at FROM invite_codes ORDER BY id DESC')->fetchAll());
}

sendJson(404, ['error' => "Unbekannte Auth-Route: $method /$uri"]);
