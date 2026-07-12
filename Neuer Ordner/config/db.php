<?php
/**
 * config/db.php – Datenbankverbindung.
 *
 * Credentials werden aus config.php geladen (nie direkt hier eintragen).
 * Diese Datei ist deploybar – sie enthält keine Secrets.
 */

function getDb(): PDO
{
	static $pdo = null;
	if ($pdo === null) {
		$dsn = sprintf('mysql:host=%s;dbname=%s;charset=%s', DB_HOST, DB_NAME, DB_CHARSET);
		$pdo = new PDO($dsn, DB_USER, DB_PASS, [
			PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
			PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
			PDO::ATTR_EMULATE_PREPARES   => false,
		]);
		$pdo->exec("SET time_zone = '+00:00'");
	}
	return $pdo;
}
