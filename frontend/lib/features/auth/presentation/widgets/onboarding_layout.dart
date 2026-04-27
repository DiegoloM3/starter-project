import 'package:flutter/material.dart';

import 'package:news_app_clean_architecture/core/theme/app_colors.dart';
import 'package:news_app_clean_architecture/core/theme/app_metrics.dart';

class OnboardingLayout extends StatelessWidget {
  const OnboardingLayout({
    super.key,
    required this.currentStep,
    required this.child,
    required this.bottomButton,
  }) : assert(currentStep >= 1 && currentStep <= 3,
            'currentStep must be 1, 2, or 3');

  final int currentStep;
  final Widget child;
  final Widget bottomButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppMetrics.w(16),
                vertical: AppMetrics.h(12),
              ),
              child: _ProgressBar(currentStep: currentStep),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppMetrics.w(16),
                ).copyWith(
                  top: AppMetrics.h(24),
                  bottom: AppMetrics.h(24),
                ),
                child: child,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppMetrics.w(16),
                vertical: AppMetrics.h(16),
              ),
              child: bottomButton,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index < currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: index == 0 ? 0 : AppMetrics.w(4)),
            height: AppMetrics.h(3),
            decoration: BoxDecoration(
              color: isActive ? AppColors.accent : AppColors.border,
              borderRadius: BorderRadius.circular(AppMetrics.r(2)),
            ),
          ),
        );
      }),
    );
  }
}
