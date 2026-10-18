import 'package:flutter/material.dart';

/// Full width button that shows a spinner and ignores taps while submitting.
class SubmitButton extends StatelessWidget {
  final String label;
  final bool isSubmitting;
  final VoidCallback onPressed;

  const SubmitButton({super.key, required this.label, required this.isSubmitting, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final spinnerColor = Theme.of(context).colorScheme.onPrimary;
    return FilledButton(
      onPressed: isSubmitting ? null : onPressed,
      child:
          isSubmitting
              ? SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: spinnerColor))
              : Text(label),
    );
  }
}
