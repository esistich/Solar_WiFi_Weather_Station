<?php
/**
 * SWS API – Router
 *
 * Alle /sws/api/*-Anfragen landen hier (via .htaccess Rewrite).
 * Statische Dateien (.css, .js, .bin, etc.) werden direkt von Apache bedient.
 */

declare(strict_types=1);

$configDir = __DIR__ . '/config';
require_once $configDir . '/config.php';
require_once $configDir . '/db.php';
require_once $configDir . '/auth.php';
require_once $configDir . '/jwt.php';
require_once __DIR__ . '/helpers.php';

// ── URI parsen ────────────────────────────────────────────────────────
$uri    = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);
$uri    = trim(preg_replace('#^.*?/sws/api#', '', $uri), '/');
if (preg_match('#^v1/(.*)$#', $uri, $m)) {
	$uri = $m[1];
}
$uri    = '/' . $uri;
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

// Legacy: ?r=route Fallback
if ($uri === '/' || $uri === '/index.php') {
	$r = trim($_GET['r'] ?? '', '/');
	if ($r !== '') $uri = '/' . $r;
}

// ── Admin-Routen → admin.php ─────────────────────────────────────────
// /admin, /admin/, /  (ohne query) → Admin-Dashboard
if ($uri === '/admin' || $uri === '/admin/' || $uri === '/' || $uri === '' || $uri === '/index.php') {
	require __DIR__ . '/admin.php';
	exit;
}

// ── API-Routing ──────────────────────────────────────────────────────
header('Content-Type: application/json; charset=utf-8');
sendCorsHeaders();

$routes = [
	'GET /data'             => __DIR__ . '/data.php',
	'POST /data'            => __DIR__ . '/data.php',
	'GET /history'          => __DIR__ . '/history.php',
	'GET /status'           => __DIR__ . '/status.php',
	'GET /stations'         => __DIR__ . '/stations.php',
	'PATCH /stations'       => __DIR__ . '/stations.php',
	'GET /metrics'          => __DIR__ . '/metrics.php',
	'GET /log'              => __DIR__ . '/log.php',
	'POST /log'             => __DIR__ . '/log.php',
	'GET /config'           => __DIR__ . '/config.php',
	'GET /zambretti'        => __DIR__ . '/zambretti.php',
	'POST /auth/login'      => __DIR__ . '/auth.php',
	'POST /auth/register'   => __DIR__ . '/auth.php',
	'POST /auth/logout'     => __DIR__ . '/auth.php',
	'POST /push/register'   => __DIR__ . '/auth.php',
	'POST /push/unregister' => __DIR__ . '/auth.php',
	'POST /invite/create'   => __DIR__ . '/auth.php',
	'GET /invite/list'      => __DIR__ . '/auth.php',
];

$key = "$method $uri";
if (isset($routes[$key]) && file_exists($routes[$key])) {
	require $routes[$key];
	exit;
}

// ── 404 ──────────────────────────────────────────────────────────────
logSystemEvent('warning', 'router', 'ROUTE_404', "Unbekannte Route: $method $uri", [
	'query' => $_SERVER['QUERY_STRING'] ?? '',
]);
http_response_code(404);
echo json_encode(['error' => "Unbekannte Route: $method $uri"], JSON_UNESCAPED_UNICODE);
