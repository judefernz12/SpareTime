import 'package:flutter/material.dart';
import 'usage_tracking_service.dart';
import 'user_data_service.dart';
import 'payment_service.dart';
import 'overlay_service.dart';

class AppAccessService {
  static Map<String, double> extraTimeGrants = {}; // Track extra time granted per app
  static DateTime lastResetDate = DateTime.now(); // Track when daily counts were last reset

  /// Checks if the user has exceeded their usage limit for specified apps
  /// Returns a map of app package names to boolean indicating if access is allowed
  static Future<Map<String, bool>> checkAccess(List<String> packageNames) async {
    // Reset daily counts if it's a new day
    final now = DateTime.now();
    if (now.day != lastResetDate.day || now.month != lastResetDate.month || now.year != lastResetDate.year) {
      PaymentService.resetDailyUnlockCount();
      extraTimeGrants.clear();
      lastResetDate = now;
    }

    // Get usage limits and selected apps
    final limits = await UserDataService.loadLimits();
    final usageMap = await UsageTrackingService.getTodayUsage(packageNames);
    final accessMap = <String, bool>{};

    for (final packageName in packageNames) {
      if (!limits.containsKey(packageName)) {
        accessMap[packageName] = true; // No limit set, allow access
        continue;
      }

      final limit = limits[packageName] ?? 0.0;
      final usage = usageMap[packageName] ?? 0.0;
      final extraTime = extraTimeGrants[packageName] ?? 0.0;
      final totalAllowedTime = limit + extraTime;

      accessMap[packageName] = usage < totalAllowedTime;
      debugPrint('Access check for $packageName: Usage=$usage, Limit=$limit, Extra=$extraTime, Allowed=${accessMap[packageName]}');
    }

    return accessMap;
  }

  /// Prompts user to pay for extra time if limit exceeded for an app
  /// Returns true if extra time is granted, false otherwise
  static Future<bool> requestExtraTime(BuildContext context, String packageName) async {
    // Calculate the fee for extra time
    final fee = PaymentService.calculateFee();

    // Show payment dialog to user
    final bool? paymentAgreed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Usage Limit Exceeded'),
          content: Text(
            'You have exceeded your usage limit for this app. '
            'Pay \$$fee to unlock extra time?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Pay Now'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (paymentAgreed != true) {
      debugPrint('User declined payment for extra time on $packageName');
      return false;
    }

    // Process payment
    final paymentSuccess = await PaymentService.processPayment(fee);
    if (!paymentSuccess) {
      debugPrint('Payment processing failed for $packageName');
      // Show failure message to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed. Access denied.')),
      );
      return false;
    }

    // Grant extra time upon successful payment
    final extraTime = await PaymentService.grantExtraTime(packageName, fee);
    extraTimeGrants.update(packageName, (value) => value + extraTime, ifAbsent: () => extraTime);

    // Remove overlay since extra time is granted
    await OverlayService.removeOverlay();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment successful! Granted $extraTime minutes extra time.')),
    );

    debugPrint('Extra time granted for $packageName: $extraTime minutes');
    return true;
  }
}
