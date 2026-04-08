import 'package:flutter/material.dart';

class SubmitProgress extends StatelessWidget {
  final String label;

  const SubmitProgress({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
