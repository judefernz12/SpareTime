import 'package:flutter/material.dart';

class AIAppealDialog extends StatefulWidget {
  final void Function(bool approved, int minutes, String reason) onResult;
  const AIAppealDialog({Key? key, required this.onResult}) : super(key: key);

  @override
  State<AIAppealDialog> createState() => _AIAppealDialogState();
}

class _AIAppealDialogState extends State<AIAppealDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _submitting = false;
  String? _resultMsg;
  int _appealsLeft = 2;

  void _submit() async {
    if (_appealsLeft <= 0) {
      setState(() {
        _resultMsg = 'Strict Mom: No more appeals left today!';
      });
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 1));
    final reason = _controller.text.trim().toLowerCase();
    bool approved = false;
    int minutes = 0;
    String feedback;
    if (reason.contains('work') || reason.contains('study')) {
      approved = true;
      minutes = 20;
      feedback = 'Strict Mom: Work or study? Okay, 20 more minutes. Don\'t waste it!';
    } else if (reason.contains('urgent') || reason.contains('emergency')) {
      approved = true;
      minutes = 30;
      feedback = 'Strict Mom: Emergency? You get 30 minutes. Use it wisely!';
    } else if (reason.contains('bored') || reason.contains('tired')) {
      approved = false;
      feedback = 'Strict Mom: Being bored isn\'t a good enough reason! No extra time.';
    } else if (reason.length > 30) {
      approved = true;
      minutes = 10;
      feedback = 'Strict Mom: You get 10 minutes for a thoughtful answer.';
    } else {
      approved = false;
      feedback = 'Strict Mom: That excuse is too weak. No extra time!';
    }
    setState(() {
      _resultMsg = feedback;
      _submitting = false;
      if (_appealsLeft > 0) _appealsLeft--;
    });
    widget.onResult(approved, minutes, reason);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Appeal to Strict Mom AI'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Appeals left today:  a0$_appealsLeft', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Why do you need more time?',
              border: OutlineInputBorder(),
            ),
          ),
          if (_resultMsg != null) ...[
            const SizedBox(height: 12),
            Text(_resultMsg!, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting ? const CircularProgressIndicator() : const Text('Submit Appeal'),
        ),
      ],
    );
  }
}
