import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/core/theme/app_colors.dart';
import 'package:news_app_clean_architecture/core/theme/app_metrics.dart';
import 'package:news_app_clean_architecture/core/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/core/widgets/app_button.dart';
import 'package:news_app_clean_architecture/core/widgets/app_card.dart';
import 'package:news_app_clean_architecture/core/widgets/app_text.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/onboarding_layout.dart';

class OnboardingRoleScreen extends StatefulWidget {
  const OnboardingRoleScreen({super.key});

  @override
  State<OnboardingRoleScreen> createState() => _OnboardingRoleScreenState();
}

class _OnboardingRoleScreenState extends State<OnboardingRoleScreen> {
  String? _selectedRole;
  bool _submitted = false;

  /// Tracks the intended navigation target so the BlocListener can decide
  /// where to go after a successful update.
  String? _nextRoute;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final role = authState.user.role;
      if (role == 'reader' || role == 'writer') {
        _selectedRole = role;
      }
    }
  }

  void _onContinue() {
    if (_selectedRole == null) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _submitted = true);

    if (_selectedRole == 'writer') {
      _nextRoute = AppRoutes.onboardingProfile;
      context.read<AuthCubit>().updateUserProfile(
            authState.user.copyWith(
              role: _selectedRole,
              onboardingStep: 2,
            ),
          );
    } else {
      // Reader skips profile — mark onboarding as completed.
      _nextRoute = AppRoutes.home;
      context.read<AuthCubit>().updateUserProfile(
            authState.user.copyWith(
              role: _selectedRole,
              onboardingStep: 3,
              onboardingCompleted: true,
            ),
          );
    }
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (!_submitted) return;

    if (state is AuthAuthenticated) {
      _submitted = false;
      if (_nextRoute == AppRoutes.home) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
      } else {
        Navigator.of(context).pushNamed(_nextRoute!);
      }
    } else if (state is AuthError) {
      _submitted = false;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: _handleAuthState,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isLoading = _submitted && state is AuthLoading;

          return OnboardingLayout(
            currentStep: 2,
            bottomButton: AppButton(
              label: 'Start exploring →',
              isLoading: isLoading,
              onPressed:
                  _selectedRole != null && !isLoading ? _onContinue : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  "What's your goal today?",
                  variant: AppTextVariant.displayLarge,
                ),
                SizedBox(height: AppSpacing.xs),
                const AppText(
                  'Choose your initial role. You can change it anytime from your Profile.',
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: AppSpacing.xl),

                // ── Reader card ──
                _RoleCard(
                  icon: Icons.menu_book_outlined,
                  title: 'Reader Mode',
                  subtitle: 'I want to research and read',
                  description:
                      'Access curated articles based on your interests. No distractions.',
                  isSelected: _selectedRole == 'reader',
                  onTap: () => setState(() => _selectedRole = 'reader'),
                ),

                SizedBox(height: AppSpacing.md),

                // ── Writer card ──
                _RoleCard(
                  icon: Icons.edit_outlined,
                  title: 'Writer Mode',
                  subtitle: 'I want to share my vision',
                  description:
                      'Publish articles, manage your drafts and build your audience.',
                  isSelected: _selectedRole == 'writer',
                  onTap: () => setState(() => _selectedRole = 'writer'),
                ),

                SizedBox(height: AppSpacing.lg),

                // ── Info banner ──
                AppCard(
                  variant: AppCardVariant.dark,
                  padding: EdgeInsets.all(AppMetrics.w(12)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16.r,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: AppMetrics.w(8)),
                      const Expanded(
                        child: AppText(
                          'You can switch between Reader and Writer anytime from Profile → Role.',
                          variant: AppTextVariant.bodySmall,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private role card widget
// ─────────────────────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final contentColor =
        isSelected ? AppColors.accent : AppColors.textSecondary;

    return AppCard(
      variant: AppCardVariant.light,
      isSelected: isSelected,
      onTap: onTap,
      padding: EdgeInsets.all(AppMetrics.w(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20.r, color: contentColor),
          ),
          SizedBox(width: AppMetrics.w(12)),

          // Text column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.titleLarge,
                ),
                SizedBox(height: AppMetrics.h(2)),
                AppText(
                  subtitle,
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: AppMetrics.h(6)),
                AppText(
                  description,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          SizedBox(width: AppMetrics.w(8)),

          // Radio-style circle indicator
          Container(
            width: 20.r,
            height: 20.r,
            margin: EdgeInsets.only(top: AppMetrics.h(2)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
                width: isSelected ? 6.r : 1.5.r,
              ),
              color: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }
}
