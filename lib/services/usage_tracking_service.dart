import 'package:usage_stats/usage_stats.dart';

class UsageTrackingService {
  // Returns a map of app package names to usage in minutes for today
  static Future<Map<String, double>> getTodayUsage(List<String> packageNames) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = now;
    Map<String, double> usageMap = {};
    try {
      List<UsageInfo> infos = await UsageStats.queryUsageStats(start, end);
      for (final info in infos) {
        // Defensive: info.packageName and info.totalTimeInForeground may be null
        final packageName = info.packageName ?? '';
        if (packageNames.contains(packageName)) {
          int millis = 0;
          if (info.totalTimeInForeground is int) {
            millis = info.totalTimeInForeground as int;
          } else if (info.totalTimeInForeground is double) {
            millis = (info.totalTimeInForeground as double).toInt();
          }
          final minutes = millis / 60000.0;
          usageMap[packageName] = minutes;
        }
      }
    } catch (e) {
      // If permission not granted or error, return empty map
      return {};
    }
    return usageMap;
  }
}
