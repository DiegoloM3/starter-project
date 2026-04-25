import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/core/theme/app_colors.dart';
import 'package:news_app_clean_architecture/core/theme/app_metrics.dart';
import 'package:news_app_clean_architecture/core/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/core/widgets/app_button.dart';
import 'package:news_app_clean_architecture/core/widgets/app_text.dart';
import 'package:news_app_clean_architecture/core/widgets/category_card.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/onboarding_layout.dart';

const _categories = [
  ('Technology', Icons.computer_outlined),
  ('Design', Icons.wb_sunny_outlined),
  ('World', Icons.language_outlined),
  ('Business', Icons.bar_chart_outlined),
  ('Culture', Icons.music_note_outlined),
  ('Science', Icons.science_outlined),
  ('Health', Icons.favorite_border),
  ('Politics', Icons.star_border),
  ('Sports', Icons.sports_basketball_outlined),
];

class OnboardingCategoriesScreen extends StatefulWidget {
  const OnboardingCategoriesScreen({super.key});

  @override
  State<OnboardingCategoriesScreen> createState() =>
      _OnboardingCategoriesScreenState();
}

class _OnboardingCategoriesScreenState
    extends State<OnboardingCategoriesScreen> {
  final Set<String> _selected = {};
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _selected.addAll(authState.user.preferredCategories);
    }
  }

  void _toggle(String category) {
    setState(() {
      if (_selected.contains(category)) {
        _selected.remove(category);
      } else {
        _selected.add(category);
      }
    });
  }

  void _onContinue() {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _submitted = true);

    context.read<AuthCubit>().updateUserProfile(
          authState.user.copyWith(
            preferredCategories: _selected.toList(),
            onboardingStep: 1,
          ),
        );
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (!_submitted) return;

    if (state is AuthAuthenticated) {
      _submitted = false;
      Navigator.of(context).pushNamed(AppRoutes.onboardingRole);
    } else if (state is AuthError) {
      _submitted = false;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (3 - _selected.length).clamp(0, 3);
    final allSet = _selected.length >= 3;

    return BlocListener<AuthCubit, AuthState>(
      listener: _handleAuthState,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isLoading = _submitted && state is AuthLoading;

          return OnboardingLayout(
            currentStep: 1,
            bottomButton: AppButton(
              label: 'Continue →',
              isLoading: isLoading,
              onPressed: allSet && !isLoading ? _onContinue : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Personalize your feed',
                  variant: AppTextVariant.displayLarge,
                ),
                SizedBox(height: AppSpacing.xs),
                const AppText(
                  'Select at least 3 topics to get started.',
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: AppSpacing.sm),
                _CounterRow(
                  selectedCount: _selected.length,
                  remaining: remaining,
                  allSet: allSet,
                ),
                SizedBox(height: AppSpacing.lg),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppMetrics.w(8),
                  mainAxisSpacing: AppMetrics.h(8),
                  childAspectRatio: 1,
                  children: [
                    for (final (label, icon) in _categories)
                      CategoryCard(
                        category: label,
                        icon: icon,
                        isSelected: _selected.contains(label),
                        onTap: () => _toggle(label),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.selectedCount,
    required this.remaining,
    required this.allSet,
  });

  final int selectedCount;
  final int remaining;
  final bool allSet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20.r,
          height: 20.r,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$selectedCount',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
        SizedBox(width: AppMetrics.w(6)),
        AppText(
          allSet ? 'All set!' : '$remaining more to go',
          variant: AppTextVariant.bodySmall,
          color: allSet ? AppColors.accent : AppColors.textSecondary,
        ),
      ],
    );
  }
}
