import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/primary_button.dart';

/// Block shown where the lead story would be when the provider cannot be
/// reached: a red rule, the reason in plain words and one button. Own
/// articles keep rendering underneath.
class FeedErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const FeedErrorCard({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.xl, AppSpacing.screenMargin, AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(left: BorderSide(color: palette.primary, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_off_rounded, color: palette.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text('OFFLINE', style: AppTypography.overline.copyWith(color: palette.primaryDeep)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text("Couldn't load the news", style: AppTypography.cardTitle.copyWith(color: palette.ink)),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: AppTypography.bodySmall.copyWith(color: palette.inkBody)),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(label: 'Try again', icon: Icons.refresh_rounded, onPressed: onRetry),
        ],
      ),
    );
  }
}
