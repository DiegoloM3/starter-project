import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_decorations.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_typography.dart';

class TortuQuoteBlock extends StatelessWidget {
  final String text;

  const TortuQuoteBlock({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.quoteBlock,
      child: Text(
        '"$text"',
        style: AppTypography.body.copyWith(
          fontStyle: FontStyle.italic,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
