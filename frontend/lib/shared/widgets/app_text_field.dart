import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/theme.dart';

/// Labeled text field applying the dark-theme design system.
/// Handles border states (enabled/focused/error) and optional footer widget.
class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final int? maxLength;
  final int minLines;
  final int? maxLines;
  final TextStyle inputStyle;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;
  final Color? counterHighlightColor;
  final Widget? footer;

  const AppTextField({
    Key? key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
    this.inputStyle = AppTextStyles.input,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.counterHighlightColor,
    this.footer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xs + 2),
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          minLines: minLines,
          maxLines: maxLines,
          style: inputStyle,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.hint,
            filled: true,
            fillColor: AppColors.surface,
            counterStyle: TextStyle(
              color: counterHighlightColor ?? AppColors.textHint,
              fontSize: 11,
            ),
            border: _border(null),
            enabledBorder: _border(AppColors.surfaceBorder),
            focusedBorder: _border(AppColors.accent),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 14,
            ),
          ),
          autovalidateMode: autovalidateMode,
          validator: validator,
        ),
        if (footer != null) ...[
          const SizedBox(height: AppSpacing.sm),
          footer!,
        ],
      ],
    );
  }

  OutlineInputBorder _border(Color? color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: color ?? Colors.transparent),
      );
}
