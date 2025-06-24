import 'package:device_apps/device_apps.dart';

class AppDisplayInfo {
  final String packageName;
  final String appName;
  final List<int>? iconBytes;
  AppDisplayInfo({required this.packageName, required this.appName, this.iconBytes});
}

class AppDisplayService {
  static Future<List<AppDisplayInfo>> getDisplayInfoForPackages(List<String> packageNames) async {
    List<AppDisplayInfo> result = [];
    for (final pkg in packageNames) {
      final app = await DeviceApps.getApp(pkg, true);
      if (app is ApplicationWithIcon) {
        result.add(AppDisplayInfo(
          packageName: pkg,
          appName: app.appName,
          iconBytes: app.icon,
        ));
      } else if (app != null) {
        result.add(AppDisplayInfo(
          packageName: pkg,
          appName: app.appName,
        ));
      }
    }
    return result;
  }
}
