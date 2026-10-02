import 'package:flutter/material.dart';

/// Says that something could not be loaded, with a button to try again.
class LoadFailureMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const LoadFailureMessage({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Try again')),
      ],
    );
  }
}
