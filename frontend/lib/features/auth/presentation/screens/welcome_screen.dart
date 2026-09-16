import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/primary_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/secondary_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/brand_mark.dart';

/// First screen without a session: the mark, the wordmark set like a
/// masthead over a rule, and the two ways in. No carousel, nothing to swipe.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.xxl, AppSpacing.screenMargin, AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const BrandMark(size: 88),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'HEADLINE\nNEWS',
                style: AppTypography.display.copyWith(color: palette.ink, fontSize: 56, height: 0.9),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: palette.ink, width: AppRules.strong)),
                ),
                child: Row(
                  children: [
                    Container(width: 7, height: 7, color: palette.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('THE DAY, IN YOUR HANDS', style: AppTypography.caption.copyWith(color: palette.inkSecondary)),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              PrimaryButton(label: 'Sign in', onPressed: context.goToSignIn),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(label: 'Create account', onPressed: context.goToSignUp),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'By continuing you agree to our terms and privacy policy.'.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTypography.captionSmall.copyWith(color: palette.inkSecondary, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
