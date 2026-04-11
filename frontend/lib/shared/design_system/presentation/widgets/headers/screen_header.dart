import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/ui_elements/app_icon_button.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const ScreenHeader({
    super.key,
    required this.title,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIconButton(icon: Icons.chevron_left, onPressed: onBackPressed),
        const SizedBox(width: AppDimensions.spacing14),
        Text(
          title,
          style: AppTypography.sectionTitle.copyWith(
            color: context.colors.textPrimary,
            letterSpacing: AppDimensions.letterSpacingTight,
          ),
        ),
      ],
    );
  }
}
