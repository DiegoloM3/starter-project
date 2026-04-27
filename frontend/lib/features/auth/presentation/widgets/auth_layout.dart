import 'package:flutter/material.dart';

import 'package:news_app_clean_architecture/core/theme/app_colors.dart';
import 'package:news_app_clean_architecture/core/theme/app_metrics.dart';
import 'package:news_app_clean_architecture/core/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/core/theme/app_typography.dart';
import 'package:news_app_clean_architecture/core/widgets/app_logo.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.child,
    this.showBackButton = false,
    this.showLogo = true,
  });

  final Widget child;
  final bool showBackButton;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppMetrics.w(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppMetrics.h(24)),
              if (showBackButton)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context).maybePop(),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              if (showLogo) ...[
                const AppLogo(size: 64),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Pulse News',
                  style: AppTypography.displayMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Your stories. Your voice.',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xl),
              ],
              child,
              SizedBox(height: AppMetrics.h(24)),
            ],
          ),
        ),
      ),
    );
  }
}
