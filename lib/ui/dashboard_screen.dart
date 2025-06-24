import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_notifier.dart';
import '../services/user_data_service.dart';
import '../services/usage_tracking_service.dart';
import '../services/app_display_service.dart';
import 'package:device_apps/device_apps.dart';
import 'mascot_widget.dart';
import 'reward_badge.dart';
import 'dart:typed_data';
import 'ai_appeal_dialog.dart';
import '../services/ads_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reward_confetti.dart';
import '../services/app_access_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, double> _limits = {};
  bool _loading = true;
  int _mockPoints = 0;
  int _mockStreak = 0;
  Map<String, double> _usageToday = {};
  bool _usageLoading = false;
  List<AppDisplayInfo> _displayApps = [];
  bool _displayLoading = false;

  int _rewardedAdCount = 0;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _loadLimits();
    _mockPoints = 100 + _limits.length * 10; // Example: 10 points per limit
    _mockStreak = _limits.isNotEmpty ? 3 : 0; // Example: streak if any limits
    _loadUsage();
    _loadDisplayApps();
    _loadRewardedAdCount();
  }

  Future<void> _loadLimits() async {
    final limits = await UserDataService.loadLimits();
    setState(() {
      _limits = limits;
      _loading = false;
    });
  }

  Future<void> _loadUsage() async {
    setState(() {
      _usageLoading = true;
    });
    // Use app names as package names for mock/demo; replace with real package names in production
    final usage = await UsageTrackingService.getTodayUsage(_limits.keys.toList());
    setState(() {
      _usageToday = usage;
      _usageLoading = false;
    });
  }

  Future<void> _loadDisplayApps() async {
    setState(() {
      _displayLoading = true;
    });
    final displayApps = await AppDisplayService.getDisplayInfoForPackages(_limits.keys.toList());
    setState(() {
      _displayApps = displayApps;
      _displayLoading = false;
    });
  }

  Future<void> _loadRewardedAdCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('rewardedAdCount') ?? 0;
    final lastDateStr = prefs.getString('rewardedAdDate');
    final today = DateTime.now();
    DateTime? lastDate = lastDateStr != null ? DateTime.tryParse(lastDateStr) : null;
    if (lastDate == null || lastDate.year != today.year || lastDate.month != today.month || lastDate.day != today.day) {
      // New day, reset count
      await prefs.setInt('rewardedAdCount', 0);
      await prefs.setString('rewardedAdDate', today.toIso8601String());
      setState(() {
        _rewardedAdCount = 0;
      });
    } else {
      setState(() {
        _rewardedAdCount = count;
      });
    }
  }

  Future<void> _incrementRewardedAdCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    _rewardedAdCount++;
    await prefs.setInt('rewardedAdCount', _rewardedAdCount);
    await prefs.setString('rewardedAdDate', today.toIso8601String());
  }

  int _calculateProgressLevel() {
    // Placeholder logic: happy if 3+ limits, neutral if 1-2, sad if 0
    if (_limits.length >= 3) return 2;
    if (_limits.length >= 1) return 1;
    return 0;
  }

  List<RewardBadge> _mockBadges() {
    // Example: badges for points and streaks
    return [
      if (_mockPoints >= 100)
        const RewardBadge(label: '100+ Points', icon: Icons.emoji_events, color: Colors.amber),
      if (_mockStreak >= 3)
        const RewardBadge(label: '3-Day Streak', icon: Icons.local_fire_department, color: Colors.redAccent),
    ];
  }

  void _showAIAppealDialog() {
    showDialog(
      context: context,
      builder: (context) => AIAppealDialog(
        onResult: (approved, minutes, reason) {
          if (approved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You got $minutes extra minutes!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No extra time granted.')),
            );
          }
        },
      ),
    );
  }

  Future<void> _showRewardedAdForApp(String packageName) async {
    if (_rewardedAdCount >= 3) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Limit Reached'),
          content: const Text('You have reached the daily ad reward limit. Try again tomorrow!'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      return;
    }
    AdsService.loadRewardedAd(() {
      AdsService.showRewardedAd(
        onRewarded: () async {
          final current = _limits[packageName] ?? 0;
          final newLimit = current + 15;
          _limits[packageName] = newLimit;
          await UserDataService.saveLimits(_limits);
          await _incrementRewardedAdCount();
          setState(() {
            _showConfetti = true;
          });
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Stack(
              alignment: Alignment.center,
              children: [
                Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.celebration, color: Colors.amber, size: 48),
                        const SizedBox(height: 16),
                        Text('Reward Granted!', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 12),
                        Text('15 minutes added to ${packageName.split(".").last}.', textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _showConfetti = false;
                            });
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showConfetti) RewardConfetti(play: true),
              ],
            ),
          );
        },
        onClosed: () {},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpareTime Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(themeNotifier.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: themeNotifier.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => context.read<ThemeNotifier>().toggleTheme(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: MascotWidget(progressLevel: _calculateProgressLevel()),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAIAppealDialog,
                    icon: const Icon(Icons.mood_bad),
                    label: const Text('Appeal to Strict Mom AI'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.star, color: AppTheme.accent),
                          const SizedBox(height: 4),
                          Text('Points', style: Theme.of(context).textTheme.labelLarge),
                          Text('$_mockPoints', style: Theme.of(context).textTheme.headlineSmall),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.local_fire_department, color: AppTheme.warning),
                          const SizedBox(height: 4),
                          Text('Streak', style: Theme.of(context).textTheme.labelLarge),
                          Text('$_mockStreak', style: Theme.of(context).textTheme.headlineSmall),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_mockBadges().isNotEmpty)
                    Column(
                      children: [
                        Text('Rewards', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _mockBadges(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  Text(
                    'Your App Limits',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _limits.isEmpty
                        ? const Center(child: Text('No limits set.'))
                        : ListView(
                            children: _limits.entries.map((entry) {
                              return Card(
                                child: ListTile(
                                  leading: Icon(Icons.apps, color: AppTheme.primary),
                                  title: Text(entry.key),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${entry.value.round()} min/day'),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.play_circle_fill, color: Colors.green),
                                        tooltip: 'Watch ad to add 15 min',
                                        onPressed: () => _showRewardedAdForApp(entry.key),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.payment, color: Colors.blue),
                                        tooltip: 'Pay to add extra time',
                                        onPressed: () async {
                                          bool accessGranted = await AppAccessService.requestExtraTime(context, entry.key);
                                          if (accessGranted) {
                                            // Refresh usage data after granting extra time
                                            await _loadUsage();
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text('Today\'s Usage', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  _usageLoading || _displayLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Expanded(
                          child: _limits.isEmpty
                              ? const Center(child: Text('No limits set.'))
                              : ListView(
                                  children: _displayApps.map((appInfo) {
                                    final usage = _usageToday[appInfo.packageName] ?? 0;
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.07),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          ListTile(
                                            leading: appInfo.iconBytes != null
                                                ? CircleAvatar(backgroundImage: MemoryImage(Uint8List.fromList(appInfo.iconBytes!)))
                                                : Icon(Icons.apps, color: AppTheme.primary),
                                            title: Text(appInfo.appName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            subtitle: Text('Used: ${usage.round()} min'),
                                            trailing: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: AppTheme.accent.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '${_limits[appInfo.packageName]?.round() ?? 0} min/day',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.secondary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                            child: ProgressBar(
                                              value: (_limits[appInfo.packageName] ?? 1) == 0 ? 0 : (usage / (_limits[appInfo.packageName] ?? 1)).clamp(0.0, 1.0),
                                              color: usage <= (_limits[appInfo.packageName] ?? 1)
                                                  ? AppTheme.success
                                                  : AppTheme.warning,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),
                ],
              ),
            ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double value;
  final Color color;

  const ProgressBar({Key? key, required this.value, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 8,
        backgroundColor: Colors.grey.shade200,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
