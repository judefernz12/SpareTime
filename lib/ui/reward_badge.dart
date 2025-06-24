import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RewardBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const RewardBadge({Key? key, required this.label, required this.icon, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
        ),
      ],
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color color;
  const ProgressBar({Key? key, required this.value, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 10,
        backgroundColor: color.withOpacity(0.15),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
