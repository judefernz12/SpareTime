import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_bottom, size: 80, color: AppTheme.accent),
            const SizedBox(height: 24),
            Text('SpareTime', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 12),
            Text('Master your habits, evolve your world.', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
