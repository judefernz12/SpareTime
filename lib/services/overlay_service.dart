import 'package:flutter/services.dart';

class OverlayService {
  static const platform = MethodChannel('overlay_control');

  /// Requests to show the overlay for a specific app
  static Future<void> showOverlay(String packageName, String appName) async {
    try {
      await platform.invokeMethod('showOverlay', {
        'packageName': packageName,
        'appName': appName,
      });
    } on PlatformException catch (e) {
      print("Failed to show overlay: '${e.message}'.");
    }
  }

  /// Requests to remove the overlay
  static Future<void> removeOverlay() async {
    try {
      await platform.invokeMethod('removeOverlay');
    } on PlatformException catch (e) {
      print("Failed to remove overlay: '${e.message}'.");
    }
  }

  /// Sends the list of restricted apps and their limits to native side
  static Future<void> updateRestrictedApps(Map<String, double> limits) async {
    try {
      await platform.invokeMethod('updateRestrictedApps', {
        'limits': limits,
      });
    } on PlatformException catch (e) {
      print("Failed to update restricted apps: '${e.message}'.");
    }
  }

  /// Checks if the necessary permissions are granted
  static Future<bool> checkPermissions() async {
    try {
      final bool result = await platform.invokeMethod('checkPermissions');
      return result;
    } on PlatformException catch (e) {
      print("Failed to check permissions: '${e.message}'.");
      return false;
    }
  }

  /// Requests necessary permissions from the user
  static Future<void> requestPermissions() async {
    try {
      await platform.invokeMethod('requestPermissions');
    } on PlatformException catch (e) {
      print("Failed to request permissions: '${e.message}'.");
    }
  }
}
