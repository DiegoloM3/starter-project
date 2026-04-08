import 'package:flutter/material.dart';

class PublishAction extends StatelessWidget {
  final String label;
  final bool disabled;
  final VoidCallback onPressed;

  const PublishAction({
    Key? key,
    required this.label,
    required this.disabled,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: disabled ? null : onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: disabled
              ? const Color(0xFFBBBBBB)
              : const Color(0xFF1976D2),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
