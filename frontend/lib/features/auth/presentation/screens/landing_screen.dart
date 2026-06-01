import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/tortutip_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError && state.message.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Layer 0: splash image full screen
              Image.asset(
                'assets/images/splash_logo.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),

              // Layer 1: Gradient overlay bottom to top
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.transparent, AppColors.background],
                      stops: [0.3, 0.7],
                    ),
                  ),
                ),
              ),

              // Layer 2: Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                      vertical: AppSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.pink.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusFull,
                            ),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.25),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                l10n.landingTagline,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        Text(
                          l10n.landingHeroLine1,
                          style: AppTypography.hero.copyWith(
                            color: Colors.pink.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.landingHeroLine2,
                          style: AppTypography.subtitle,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        TortuGoogleButton(
                          isLoading: state is AuthLoading,
                          onTap: () => context.read<AuthBloc>().add(
                            const SignInWithGoogleEvent(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTypography.caption,
                            children: [
                              TextSpan(
                                text: l10n.landingTermsPrefix,
                              ),
                              TextSpan(
                                text: l10n.landingTermsOfService,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary,
                                ),
                              ),
                              TextSpan(
                                text: l10n.landingTermsMiddle,
                              ),
                              TextSpan(
                                text: l10n.landingPrivacyPolicy,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
