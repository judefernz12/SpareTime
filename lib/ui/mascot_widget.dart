import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MascotWidget extends StatefulWidget {
  final int progressLevel; // 0 = sad, 1 = neutral, 2 = happy
  const MascotWidget({Key? key, required this.progressLevel}) : super(key: key);

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void didUpdateWidget(MascotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progressLevel != widget.progressLevel) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String label;
    switch (widget.progressLevel) {
      case 2:
        icon = Icons.emoji_emotions;
        color = AppTheme.success;
        label = 'Your mascot is thriving!';
        break;
      case 1:
        icon = Icons.sentiment_satisfied;
        color = AppTheme.accent;
        label = 'Your mascot is doing okay.';
        break;
      default:
        icon = Icons.sentiment_dissatisfied;
        color = AppTheme.warning;
        label = 'Your mascot is sad.';
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _animation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                center: Alignment.center,
                radius: 0.8,
              ),
            ),
            width: 96,
            height: 96,
            child: Icon(icon, size: 56, color: color),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 500),
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: color),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
