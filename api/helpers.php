<?php
/**
 * v1/helpers.php – gemeinsame Hilfsfunktionen für alle v1-Endpunkte.
 * Wird von index.php einmalig geladen.
 */
declare(strict_types=1);

if (!function_exists('resolveStation')) {
	/**
	 * Station anhand MAC (bevorzugt), dann slug ermitteln.
	 *
	 * @param  PDO         $db
	 * @param  string|null $slug  station_slug aus dem Request
	 * @param  string|null $mac   device_mac aus dem Request (normalisiert: 'aa:bb:cc:dd:ee:ff')
	 * @return array|null  ['id', 'slug', 'name', 'mac'] oder null wenn keine Station zugeordnet werden kann
	 */
	function resolveStation(PDO $db, ?string $slug, ?string $mac = null): ?array
	{
		// 1. Per MAC suchen (eindeutig, hardware-seitig garantiert)
		if ($mac) {
			$st = $db->prepare('SELECT id, slug, name, mac FROM stations WHERE mac = ? LIMIT 1');
			$st->execute([$mac]);
			$row = $st->fetch();
			if ($row) return $row;
		}

		// 2. Per slug suchen (Fallback fuer Geraete ohne MAC)
		if ($slug) {
			$st = $db->prepare('SELECT id, slug, name, mac FROM stations WHERE slug = ? LIMIT 1');
			$st->execute([$slug]);
			$row = $st->fetch();
			if ($row) return $row;
		}

		// 3. Kein Identifier vorhanden
		return null;
	}
}

if (!function_exists('normalizeMac')) {
	/** MAC-Adresse normalisieren: 'A4:CF:12:AB:34:56' → 'a4:cf:12:ab:34:56' */
	function normalizeMac(?string $mac): ?string
	{
		if (!$mac) return null;
		$clean = strtolower(preg_replace('/[^0-9a-fA-F]/', '', $mac));
		if (strlen($clean) !== 12) return null;
		return implode(':', str_split($clean, 2));
	}
}

if (!function_exists('getClientIp')) {
	/** Client-IP ermitteln (auch hinter Proxies) */
	function getClientIp(): string
	{
		foreach (['HTTP_X_FORWARDED_FOR', 'HTTP_X_REAL_IP', 'HTTP_CLIENT_IP', 'REMOTE_ADDR'] as $key) {
			$ip = $_SERVER[$key] ?? '';
			if ($ip) {
				// Bei X-Forwarded-For die erste (Client-)IP nehmen
				$parts = explode(',', $ip);
				$ip = trim($parts[0]);
				if (filter_var($ip, FILTER_VALIDATE_IP)) return $ip;
			}
		}
		return 'unknown';
	}
}

if (!function_exists('logSystemEvent')) {
	/**
	 * System-Ereignis in die system_log-Tabelle schreiben.
	 *
	 * @param string $level   'error', 'warning' oder 'info'
	 * @param string $source  'auth', 'db', 'station', 'api', 'router'
	 * @param string $code    Maschinenlesbarer Code, z.B. 'AUTH_FAILED'
	 * @param string $message Menschenlesbare Beschreibung
	 * @param array|null $context Zusatzinfos (wird als JSON gespeichert)
	 */
	function logSystemEvent(string $level, string $source, string $code, string $message = '', ?array $context = null): void
	{
		try {
			$db = getDb();
			$stmt = $db->prepare('
				INSERT INTO system_log (level, source, code, message, context, ip)
				VALUES (:level, :source, :code, :msg, :ctx, :ip)
			');
			$stmt->execute([
				':level'  => $level,
				':source' => $source,
				':code'   => substr($code, 0, 64),
				':msg'    => substr($message, 0, 512),
				':ctx'    => ($context !== null && $context !== []) ? json_encode($context, JSON_UNESCAPED_UNICODE) : null,
				':ip'     => getClientIp(),
			]);
		} catch (\Throwable $e) {
			// Logging darf niemals den normalen Ablauf stören –
			// Fehler beim Loggen werden still ignoriert.
			error_log('SWS system_log failed: ' . $e->getMessage());
		}
	}
}

// ═══════════════════════════════════════════════════════════════════
// GLOBALER CATCH-ALL: Fehler, Exceptions & Fatal Errors loggen
// ═══════════════════════════════════════════════════════════════════

/**
 * PHP-Fehler (Warnings, Notices etc.) in Exceptions umwandeln,
 * damit sie vom Exception-Handler gefangen werden.
 */
set_error_handler(function (int $severity, string $message, string $file, int $line): bool {
	// @-Suppression respektieren
	if (!(error_reporting() & $severity)) {
		return true;
	}
	throw new \ErrorException($message, 0, $severity, $file, $line);
});

/**
 * Uncaught Exceptions abfangen und loggen.
 * Danach sauberen JSON-Fehler ausgeben.
 */
set_exception_handler(function (\Throwable $e): void {
	// Nur loggen, wenn DB verfügbar ist
	try {
		$db = getDb();
		$stmt = $db->prepare('
			INSERT INTO system_log (level, source, code, message, context, ip)
			VALUES (:level, :source, :code, :msg, :ctx, :ip)
		');
		$stmt->execute([
			':level'  => 'error',
			':source' => 'php',
			':code'   => 'UNCAUGHT_' . strtoupper(basename(str_replace('\\', '/', get_class($e)))),
			':msg'    => substr($e->getMessage(), 0, 512),
			':ctx'    => json_encode([
				'file'  => $e->getFile(),
				'line'  => $e->getLine(),
				'trace' => explode("\n", $e->getTraceAsString()),
				'uri'   => $_SERVER['REQUEST_URI'] ?? 'CLI',
				'method'=> $_SERVER['REQUEST_METHOD'] ?? 'N/A',
			], JSON_UNESCAPED_UNICODE),
			':ip'     => getClientIp(),
		]);
	} catch (\Throwable $logError) {
		// Fallback: in PHP-Error-Log schreiben
		error_log(sprintf(
			'SWS UNCAUGHT %s: %s in %s:%d | URI: %s',
			get_class($e),
			$e->getMessage(),
			$e->getFile(),
			$e->getLine(),
			$_SERVER['REQUEST_URI'] ?? 'CLI'
		));
	}

	// Saubere JSON-Fehlerantwort (kein nackter Stacktrace)
	if (!headers_sent()) {
		http_response_code(500);
		header('Content-Type: application/json; charset=utf-8');
	}
	echo json_encode([
		'error'   => 'Interner Server-Fehler',
		'code'    => 'INTERNAL_ERROR',
	], JSON_UNESCAPED_UNICODE);

	exit(1);
});

/**
 * Shutdown-Handler: Fängt fatale Fehler ab (memory exhaustion,
 * max execution time, parse errors in includes etc.).
 */
register_shutdown_function(function (): void {
	$error = error_get_last();
	if (!$error) return;

	// Nur fatale Fehler-Level loggen
	$fatalLevels = [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR, E_USER_ERROR];
	if (!in_array($error['type'], $fatalLevels, true)) return;

	try {
		$db = getDb();
		$stmt = $db->prepare('
			INSERT INTO system_log (level, source, code, message, context, ip)
			VALUES (:level, :source, :code, :msg, :ctx, :ip)
		');
		$stmt->execute([
			':level'  => 'error',
			':source' => 'php',
			':code'   => 'FATAL_ERROR',
			':msg'    => substr($error['message'], 0, 512),
			':ctx'    => json_encode([
				'file'      => $error['file'],
				'line'      => $error['line'],
				'type'      => $error['type'],
				'uri'       => $_SERVER['REQUEST_URI'] ?? 'CLI',
				'method'    => $_SERVER['REQUEST_METHOD'] ?? 'N/A',
				'memory_mb' => round(memory_get_peak_usage(true) / 1048576, 1),
			], JSON_UNESCAPED_UNICODE),
			':ip'     => getClientIp(),
		]);
	} catch (\Throwable $logError) {
		error_log(sprintf(
			'SWS FATAL: %s in %s:%d | URI: %s',
			$error['message'],
			$error['file'],
			$error['line'],
			$_SERVER['REQUEST_URI'] ?? 'CLI'
		));
	}
});
