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
