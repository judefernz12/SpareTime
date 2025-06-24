import 'package:device_apps/device_apps.dart';

class InstalledAppsService {
  // Returns a list of installed apps (non-system, launchable)
  static Future<List<Application>> getInstalledApps() async {
    return await DeviceApps.getInstalledApplications(
      includeSystemApps: false,
      onlyAppsWithLaunchIntent: true,
    );
  }
}
