import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'This is a placeholder for the SpareTime privacy policy. Please update this with your real privacy policy before publishing.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
