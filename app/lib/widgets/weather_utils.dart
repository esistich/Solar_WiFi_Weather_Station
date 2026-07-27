import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

/// Hilfsfunktionen fuer Wetter-Icons, Farben, Gradienten und Zeitformatierung.
abstract final class WeatherUtils {
  
  // ── Zambretti → Icons (Mehrzahl) ──────────────────────────────────────────

  /// Analysiert den Text basierend auf den Translation_DE.h Strings.
  static List<IconData> iconsForZambretti(String zambretti) {
    final z = zambretti.toLowerCase();
    final List<IconData> icons = [];

    // 1. Sonne / Gutes Wetter
    if (z.contains('schön') || z.contains('gut') || z.contains('aufhellungen') || z.contains('klart')) {
      icons.add(Icons.wb_sunny_rounded);
    }

    // 2. Bewölkung / Veränderlich
    if (z.contains('veränderlich') || z.contains('wechselhaft') || z.contains('wechselnd') || z.contains('wolkig') || z.contains('bewölkt')) {
      icons.add(Icons.wb_cloudy_rounded);
    }

    // 3. Niederschlag (Regen/Schnee)
    if (z.contains('regen') || z.contains('schnee') || z.contains('schauer') || z.contains('nass') || z.contains('schauerhaft')) {
      icons.add(Icons.grain_rounded);
    }

    // 4. Sturm / Wind
    if (z.contains('stürmisch') || z.contains('sturm') || z.contains('unruhig')) {
      icons.add(Icons.air_rounded);
    }

    // 5. Sonderfall: Batterie
    if (z.contains('batterie') || z.contains('leer') || z.contains('nachladen')) {
      return [Icons.battery_alert_rounded];
    }

    // Fallback: Wenn gar nichts erkannt wurde
    if (icons.isEmpty) {
      if (z.contains('gut')) return [Icons.wb_sunny_rounded];
      return [Icons.thermostat_rounded];
    }
    
    // Doppelte vermeiden und auf max 3 begrenzen
    return icons.toSet().toList().take(3).toList();
  }

  /// Liefert das primäre Icon für die Kachel.
  static IconData iconForZambretti(String zambretti) {
    final icons = iconsForZambretti(zambretti);
    return icons.isNotEmpty ? icons.first : Icons.thermostat_rounded;
  }

  // ── Zambretti → Gradient ────────────────────────────────────────────────────

  static LinearGradient gradientForZambretti(String zambretti) {
	final z = zambretti.toLowerCase();
    
    if (z.contains('stürmisch') || z.contains('unruhig')) {
      return const LinearGradient(
		colors: [Color(0xFF37474F), Color(0xFF546E7A)],
		begin: Alignment.topLeft, end: Alignment.bottomRight,
	  );
    }
    
    if (z.contains('regen') || z.contains('schauer') || z.contains('schauerhaft')) {
      return const LinearGradient(
		colors: [Color(0xFF455A64), Color(0xFF78909C)],
		begin: Alignment.topLeft, end: Alignment.bottomRight,
	  );
    }

	if (z.contains('schön') || z.contains('gut') || z.contains('klar')) {
	  return const LinearGradient(
		colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
		begin: Alignment.topLeft, end: Alignment.bottomRight,
	  );
	}

	return const LinearGradient(
	  colors: [Color(0xFF37474F), Color(0xFF607D8B)],
	  begin: Alignment.topLeft, end: Alignment.bottomRight,
	);
  }

  static Color batteryColor(int pct) {
    if (pct >= 60) return const Color(0xFF66BB6A); // gruen
    if (pct >= 30) return const Color(0xFFFFA726); // orange
    return const Color(0xFFEF5350);                // rot
  }

  static String relativeTime(int ageSeconds, AppLocalizations l10n) {
    if (ageSeconds < 60) return l10n.relativeTimeJustNow;
    if (ageSeconds < 3600) {
      final min = (ageSeconds / 60).round();
      return l10n.relativeTimeMinutes(min);
    }
    if (ageSeconds < 86400) {
      final h = (ageSeconds / 3600).round();
      return l10n.relativeTimeHours(h);
    }
    final d = (ageSeconds / 86400).round();
    return l10n.relativeTimeDays(d);
  }

  static const List<IconData> deviceIcons = [
    Icons.home_rounded,         // 0 Haus
    Icons.pool_rounded,         // 1 Pool
    Icons.yard_rounded,         // 2 Garten
    Icons.balcony_rounded,      // 3 Balkon
    Icons.roofing_rounded,      // 4 Dach
    Icons.garage_rounded,       // 5 Garage
    Icons.cabin_rounded,        // 6 Hütte
    Icons.wb_cloudy_rounded,    // 7 Allgemein
  ];

  static IconData deviceIcon(int index) =>
      deviceIcons[index.clamp(0, deviceIcons.length - 1)];

  static String deviceIconLabel(int index, AppLocalizations l10n) {
    final labels = [
      l10n.deviceIconLabelHouse,
      l10n.deviceIconLabelPool,
      l10n.deviceIconLabelGarden,
      l10n.deviceIconLabelBalcony,
      l10n.deviceIconLabelRoof,
      l10n.deviceIconLabelGarage,
      l10n.deviceIconLabelCabin,
      l10n.deviceIconLabelGeneral,
    ];
    return labels[index.clamp(0, labels.length - 1)];
  }

  // ── Icon-Farben ─────────────────────────────────────────────────────────────

  static Color colorForIcon(IconData icon) {
    if (icon == Icons.wb_sunny_rounded) return Colors.amber;
    if (icon == Icons.wb_cloudy_rounded) return Colors.white.withOpacity(0.9);
    if (icon == Icons.grain_rounded) return Colors.lightBlueAccent;
    if (icon == Icons.thunderstorm_rounded) return Colors.deepPurpleAccent;
    if (icon == Icons.ac_unit_rounded) return Colors.cyanAccent;
    if (icon == Icons.air_rounded) return Colors.blueGrey.shade100;
    if (icon == Icons.battery_alert_rounded) return Colors.redAccent;
    if (icon == Icons.trending_up_rounded) return Colors.orangeAccent;
    if (icon == Icons.trending_down_rounded) return Colors.lightBlue;
    
    return Colors.white70;
  }

  // ── Drucktrend ─────────────────────────────────────────────────────────────

  static IconData trendIcon(String trend) {
    final t = trend.toLowerCase();
    if (t.contains('rasch steigend')) return Icons.keyboard_double_arrow_up;
    if (t.contains('langsam steigend')) return Icons.trending_up;
    if (t.contains('steigend')) return Icons.arrow_upward;
    if (t.contains('rasch fallend')) return Icons.keyboard_double_arrow_down;
    if (t.contains('langsam fallend')) return Icons.trending_down;
    if (t.contains('fallend')) return Icons.arrow_downward;
    return Icons.trending_flat;
  }

  static Color trendColor(String trend) {
    final t = trend.toLowerCase();
    if (t.contains('steigend')) return Colors.orange;
    if (t.contains('fallend')) return Colors.blue;
    return Colors.grey.shade700;
  }

  // ── Extra Sensoren & Übersetzung ───────────────────────────────────────────

  /// Liefert Icon und Label basierend auf dem metric_key.
  static (IconData, String) sensorInfo(String key, AppLocalizations l10n) {
    final k = key.toLowerCase();
    
    if (k == 'accuracy_pct') return (Icons.analytics_outlined, l10n.sensorLabelForecastAccuracy);
    if (k == 'dewpoint' || k == 'dewpointspread') return (Icons.water_drop_outlined, l10n.sensorLabelDewpoint);
    if (k == 'heat_index' || k == 'heatindex') return (Icons.hot_tub_rounded, l10n.sensorLabelHeatIndex);
    if (k == 'battery_volt') return (Icons.electric_bolt_rounded, l10n.sensorLabelVoltage);
    if (k == 'wifi_strength' || k == 'wifistrength') return (Icons.wifi_rounded, l10n.sensorLabelWifi);
    if (k == 'abs_pressure') return (Icons.compress_rounded, l10n.sensorLabelAbsPressure);
    if (k == 'fw_version') return (Icons.system_update_alt_rounded, l10n.sensorLabelFwVersion);
    
    // Dynamische Erkennung für andere Sensoren
    if (k.contains('co2')) return (Icons.co2_rounded, l10n.sensorLabelCo2);
    if (k.contains('pm2') || k.contains('aqi')) return (Icons.air_rounded, l10n.sensorLabelDust);
    if (k.contains('lux') || k.contains('hell')) return (Icons.light_mode_rounded, l10n.sensorLabelBrightness);
    if (k.contains('uv')) return (Icons.wb_sunny_rounded, l10n.sensorLabelUvIndex);
    
    return (Icons.sensors_rounded, key.toUpperCase().replaceAll('_', ' '));
  }

  /// Liefert die Einheit für den metric_key.
  static String sensorUnit(String key) {
    final k = key.toLowerCase();
    
    if (k.contains('pct') || k.contains('humidity') || k == 'battery_pct') return '%';
    if (k.contains('temperature') || k.contains('dewpoint') || k.contains('heat')) return '°C';
    if (k.contains('pressure')) return ' hPa';
    if (k.contains('volt')) return ' V';
    if (k == 'wifi_strength' || k == 'wifistrength') return ' dBm';
    if (k.contains('lux')) return ' lx';
    if (k.contains('co2')) return ' ppm';
    
    return '';
  }
}
