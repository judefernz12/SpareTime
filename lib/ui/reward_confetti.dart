import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class RewardConfetti extends StatefulWidget {
  final bool play;
  const RewardConfetti({Key? key, required this.play}) : super(key: key);

  @override
  State<RewardConfetti> createState() => _RewardConfettiState();
}

class _RewardConfettiState extends State<RewardConfetti> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 2));
    if (widget.play) {
      _controller.play();
    }
  }

  @override
  void didUpdateWidget(covariant RewardConfetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _controller,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: const [Colors.green, Colors.amber, Colors.blue, Colors.purple],
        numberOfParticles: 30,
        maxBlastForce: 20,
        minBlastForce: 8,
        emissionFrequency: 0.1,
        gravity: 0.3,
      ),
    );
  }
}
