import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_notifier.dart';
import 'onboarding_screen.dart'; // Import the OnboardingScreen
import 'dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpareTime'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(themeNotifier.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: themeNotifier.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => context.read<ThemeNotifier>().toggleTheme(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mascot placeholder
            CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.accent.withOpacity(0.2),
              child: Icon(Icons.emoji_emotions, size: 56, color: AppTheme.accent),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to SpareTime!',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Master your habits, evolve your world.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OnboardingScreen(),
                  ),
                );
              },
              child: const Text('Get Started'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ),
                );
              },
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
