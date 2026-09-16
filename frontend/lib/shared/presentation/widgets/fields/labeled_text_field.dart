import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// Text field with the label above, an optional live counter and a full
/// sentence error below. Height is 60dp for single-line fields.
class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final bool required;
  final bool optional;
  final int? maxLength;
  final int minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextStyle? textStyle;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;

  const LabeledTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.required = false,
    this.optional = false,
    this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.textStyle,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(label: label, required: required, optional: optional, controller: controller, maxLength: maxLength),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          minLines: obscureText ? 1 : minLines,
          maxLines: obscureText ? 1 : maxLines,
          inputFormatters: maxLength == null ? null : [LengthLimitingTextInputFormatter(maxLength)],
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: textStyle ?? AppTypography.valueLine.copyWith(color: palette.ink),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: palette.inkSecondary),
            suffixIcon: suffix,
            suffixIconConstraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
            errorText: hasError ? '' : null,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.sm),
          FieldErrorMessage(message: errorText!),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String label;
  final bool required;
  final bool optional;
  final TextEditingController? controller;
  final int? maxLength;

  const _Header({
    required this.label,
    required this.required,
    required this.optional,
    required this.controller,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              text: label,
              style: AppTypography.label.copyWith(color: palette.ink),
              children: [
                if (required)
                  TextSpan(text: ' *', style: TextStyle(color: palette.error)),
                if (optional)
                  TextSpan(
                    text: ' (optional)',
                    style: AppTypography.label.copyWith(
                      color: palette.inkSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (maxLength != null && controller != null)
          _Counter(controller: controller!, maxLength: maxLength!),
      ],
    );
  }
}

class _Counter extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;

  const _Counter({required this.controller, required this.maxLength});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final length = value.text.characters.length;
        final atLimit = length >= maxLength;
        return Text(
          '$length / $maxLength',
          style: AppTypography.captionSmall.copyWith(
            color: atLimit ? palette.error : palette.inkSecondary,
          ),
        );
      },
    );
  }
}

/// Error sentence with a leading icon, 15sp, in the error colour.
class FieldErrorMessage extends StatelessWidget {
  final String message;

  const FieldErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final error = context.palette.error;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.error_outline_rounded, size: 20, color: error),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: AppTypography.label.copyWith(color: error, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
