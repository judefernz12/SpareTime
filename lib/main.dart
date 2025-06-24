import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'theme/app_theme.dart';
import 'theme/theme_notifier.dart';
import 'ui/home_screen.dart';
import 'ui/splash_screen.dart';
import 'ui/onboarding_screen.dart';
import 'ui/dashboard_screen.dart';
import 'ui/privacy_policy_screen.dart';
import 'services/ads_service.dart';
import 'services/overlay_service.dart';
import 'services/user_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Only initialize ads and overlay on supported platforms
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await AdsService.initialize();
      await OverlayService.checkPermissions();
    }
  } catch (e, stack) {
    print('Startup plugin error: $e');
    print(stack);
    // Continue to run the app even if plugins fail
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(false),
      child: const SpareTimeApp(),
    ),
  );
}

class SpareTimeApp extends StatefulWidget {
  const SpareTimeApp({Key? key}) : super(key: key);

  @override
  State<SpareTimeApp> createState() => _SpareTimeAppState();
}

class _SpareTimeAppState extends State<SpareTimeApp> {
  bool _showSplash = true;
  bool _showOnboarding = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await Future.delayed(const Duration(seconds: 2)); // Splash duration
      final selectedApps = await UserDataService.loadSelectedApps();
      setState(() {
        _showSplash = false;
        _showOnboarding = selectedApps.isEmpty;
        _errorMessage = null;
      });
    } catch (e, stack) {
      print('Init error: $e');
      print(stack);
      setState(() {
        _showSplash = false;
        _showOnboarding = true; // fallback to onboarding
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    return MaterialApp(
      title: 'SpareTime',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _showSplash
          ? const SplashScreen()
          : _errorMessage != null
              ? Scaffold(
                  body: Center(
                    child: Text(
                      'Error:\n"+_errorMessage!',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : _showOnboarding
                  ? const OnboardingScreen()
                  : const HomeScreen(),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/privacy': (context) => const PrivacyPolicyScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
