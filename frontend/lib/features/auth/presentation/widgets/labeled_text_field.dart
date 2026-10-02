import 'package:flutter/material.dart';

/// A text field with its label above it, as in the forms of the design.
class LabeledTextField extends StatelessWidget {
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          enabled: enabled,
          obscureText: obscureText,
          autocorrect: !obscureText,
          enableSuggestions: !obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
