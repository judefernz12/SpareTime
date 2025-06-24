import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

typedef LimitsMap = Map<String, double>;

class UserDataService {
  static const _limitsKey = 'app_usage_limits';
  static const _appsKey = 'selected_apps';

  // Save limits to local storage
  static Future<void> saveLimits(LimitsMap limits) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = limits.entries.map((e) => '${e.key}:${e.value}').join(',');
    await prefs.setString(_limitsKey, encoded);
  }

  // Load limits from local storage
  static Future<LimitsMap> loadLimits() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_limitsKey);
    if (encoded == null || encoded.isEmpty) return {};
    final map = <String, double>{};
    for (final pair in encoded.split(',')) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        map[parts[0]] = double.tryParse(parts[1]) ?? 0;
      }
    }
    return map;
  }

  static Future<void> saveSelectedApps(Set<String> apps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_appsKey, apps.toList());
  }

  static Future<Set<String>> loadSelectedApps() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_appsKey);
    return list != null ? Set<String>.from(list) : {};
  }
}
