class AppUsageLimit {
  final String appName;
  final double dailyLimitMinutes;

  AppUsageLimit({required this.appName, required this.dailyLimitMinutes});
}

class UserProfile {
  final List<AppUsageLimit> limits;

  UserProfile({required this.limits});
}
