import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';

class InputTextArea extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const InputTextArea({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.maxLines = 5,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing18,
        vertical: AppDimensions.spacing16,
      ),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style:
                AppTypography.fieldLabel.copyWith(color: AppColors.accentGreen),
          ),
          const SizedBox(height: AppDimensions.spacing6),
          TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: maxLines,
            style: AppTypography.body.copyWith(
              color: colors.textPrimary,
              height: AppDimensions.lineHeightRelaxed,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: AppTypography.body.copyWith(
                color: colors.textPlaceholder,
                height: AppDimensions.lineHeightRelaxed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
