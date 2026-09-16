import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/fields/labeled_text_field.dart';

/// Password field with a labelled "Show" / "Hide" button inside it, never a
/// bare eye icon.
class PasswordField extends StatelessWidget {
  final bool obscureText;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  const PasswordField({
    super.key,
    required this.obscureText,
    required this.onChanged,
    required this.onToggleVisibility,
    this.errorText,
    this.onSubmitted,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return LabeledTextField(
      label: 'Password',
      prefixIcon: Icons.lock_outline_rounded,
      obscureText: obscureText,
      errorText: errorText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofillHints: autofillHints,
      textInputAction: TextInputAction.done,
      suffix: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: TextButton(
          onPressed: onToggleVisibility,
          child: Text(obscureText ? 'Show' : 'Hide'),
        ),
      ),
    );
  }
}
