import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_notifier.dart';
import '../services/user_data_service.dart';
import '../services/installed_apps_service.dart';
import 'package:device_apps/device_apps.dart';
import 'home_screen.dart'; // Import HomeScreen

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  final Set<String> _selectedApps = {};
  final Map<String, double> _usageLimits = {};

  List<Application> _installedApps = [];
  bool _appsLoading = false;

  Future<void> _loadInstalledApps() async {
    setState(() {
      _appsLoading = true;
    });
    final apps = await InstalledAppsService.getInstalledApps();
    setState(() {
      _installedApps = apps;
      _appsLoading = false;
    });
  }

  Widget _progressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _step == index ? AppTheme.accent : Colors.grey[300],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _step == 0
              ? _welcomeStep(context)
              : _step == 1
                  ? _appSelectionStep(context)
                  : _limitSettingStep(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<ThemeNotifier>().toggleTheme(),
        child: Icon(themeNotifier.isDarkMode ? Icons.dark_mode : Icons.light_mode),
        tooltip: 'Toggle Theme',
      ),
    );
  }

  Widget _welcomeStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        _progressIndicator(),
        const SizedBox(height: 16),
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: AppTheme.accent.withOpacity(0.2),
            child: Icon(Icons.emoji_emotions, size: 56, color: AppTheme.accent),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Welcome to SpareTime!',
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Let’s help you master your habits. Select the apps you want to limit and set your daily goals.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _step = 1;
            });
          },
          child: const Text('Get Started'),
        ),
      ],
    );
  }

  Widget _appSelectionStep(BuildContext context) {
    if (_installedApps.isEmpty && !_appsLoading) {
      _loadInstalledApps();
    }
    return _appsLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Addictive Apps',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: _installedApps.map((app) {
                    final isSelected = _selectedApps.contains(app.packageName);
                    return CheckboxListTile(
                      title: Text(app.appName),
                      value: isSelected,
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedApps.add(app.packageName);
                          } else {
                            _selectedApps.remove(app.packageName);
                          }
                        });
                      },
                      secondary: app is ApplicationWithIcon
                          ? CircleAvatar(
                              backgroundImage: MemoryImage(app.icon),
                            )
                          : null,
                    );
                  }).toList(),
                ),
              ),
              ElevatedButton(
                onPressed: _selectedApps.isNotEmpty
                    ? () {
                        setState(() {
                          _step = 2;
                        });
                      }
                    : null,
                child: const Text('Next'),
              ),
            ],
          );
  }

  Widget _limitSettingStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Set Daily Usage Limits',
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: _selectedApps.map((app) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Slider(
                    value: _usageLimits[app] ?? 60,
                    min: 10,
                    max: 300,
                    divisions: 29,
                    label: '${(_usageLimits[app] ?? 60).round()} min',
                    onChanged: (value) {
                      setState(() {
                        _usageLimits[app] = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ),
        ),
        ElevatedButton(
          onPressed: _usageLimits.length == _selectedApps.length
              ? () async {
                  await UserDataService.saveLimits(_usageLimits);
                  await UserDataService.saveSelectedApps(_selectedApps);
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                    (route) => false,
                  );
                }
              : null,
          child: const Text('Finish'),
        ),
      ],
    );
  }
}
