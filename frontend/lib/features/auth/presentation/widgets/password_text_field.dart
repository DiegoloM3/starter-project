import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';

import 'labeled_text_field.dart';

/// A password field whose eye button shows or hides what was typed.
class PasswordTextField extends StatefulWidget {
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  const PasswordTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.onSubmitted,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return LabeledTextField(
      label: widget.label,
      hint: widget.hint,
      onChanged: widget.onChanged,
      helperText: widget.helperText,
      errorText: widget.errorText,
      enabled: widget.enabled,
      obscureText: !_isPasswordVisible,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onSubmitted: widget.onSubmitted,
      suffixIcon: IconButton(
        onPressed: _togglePasswordVisibility,
        tooltip: _isPasswordVisible ? 'Hide password' : 'Show password',
        color: context.palette.icon,
        icon: Icon(_isPasswordVisible ? Ionicons.eyeOffOutline : Ionicons.eyeOutline, size: 20),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() => _isPasswordVisible = !_isPasswordVisible);
  }
}
