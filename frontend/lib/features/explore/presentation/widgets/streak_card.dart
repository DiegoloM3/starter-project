import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/l10n/app_localizations.dart';

class StreakCard extends StatelessWidget {
  final int streakDays;
  final double categoryProgress;

  const StreakCard({
    super.key,
    required this.streakDays,
    required this.categoryProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.streakBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/tortuga.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (context, error, _) => const Text(
              '🐢',
              style: AppTypography.hero,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).exploreStreakDays(streakDays),
                  style: AppTypography.h2.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppLocalizations.of(context).exploreStreakMotivation,
                  style: AppTypography.body.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: AppSpacing.iconSizeLg,
            height: AppSpacing.iconSizeLg,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: categoryProgress,
                  color: AppColors.primary,
                  strokeWidth: 3,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                ),
                Text(
                  '${(categoryProgress * 100).toStringAsFixed(0)}%',
                  style: AppTypography.micro.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
