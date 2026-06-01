import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:tortutip/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:tortutip/features/onboarding/presentation/widgets/age_range_chip.dart';
import 'package:tortutip/features/onboarding/presentation/widgets/gender_card.dart';
import 'package:tortutip/l10n/app_localizations.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/shared/widgets/tortutip_button.dart';
import 'package:tortutip/shared/widgets/tortutip_progress_dots.dart';

class OnboardingDetailsScreen extends StatefulWidget {
  const OnboardingDetailsScreen({super.key});

  @override
  State<OnboardingDetailsScreen> createState() =>
      _OnboardingDetailsScreenState();
}

class _OnboardingDetailsScreenState extends State<OnboardingDetailsScreen> {
  String? _selectedGender;
  String? _selectedAgeRange;

  bool get _canFinish => _selectedGender != null && _selectedAgeRange != null;

  void _onFinish() {
    final user = context.read<OnboardingCubit>().currentUser;
    if (user == null) return;
    final updatedUser = UserEntity(
      id: user.id,
      name: user.name,
      email: user.email,
      avatarUrl: user.avatarUrl,
      bio: user.bio,
      role: user.role,
      gender: _selectedGender!,
      ageRange: _selectedAgeRange!,
      createdAt: user.createdAt,
    );
    context.read<OnboardingCubit>().completeOnboarding(updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        if (context.canPop())
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        const Spacer(),
                        const TortuProgressDots(total: 3, current: 2),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xxl),
                      Text(l10n.onboardingDetailsTitle, style: AppTypography.h1),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Esto nos ayuda a personalizar tus recomendaciones diarias',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(l10n.onboardingDetailsGender, style: AppTypography.h4),
                      const SizedBox(height: AppSpacing.md),
                      GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 1.3,
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisSpacing: AppSpacing.sm,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          GenderCard(
                            value: 'female',
                            label: l10n.onboardingGenderFemale,
                            icon: Icons.female,
                            selected: _selectedGender == 'female',
                            onTap: () =>
                                setState(() => _selectedGender = 'female'),
                          ),
                          GenderCard(
                            value: 'male',
                            label: l10n.onboardingGenderMale,
                            icon: Icons.male,
                            selected: _selectedGender == 'male',
                            onTap: () =>
                                setState(() => _selectedGender = 'male'),
                          ),
                          GenderCard(
                            value: 'other',
                            label: l10n.onboardingGenderOther,
                            icon: Icons.transgender,
                            selected: _selectedGender == 'other',
                            onTap: () =>
                                setState(() => _selectedGender = 'other'),
                          ),
                          GenderCard(
                            value: 'prefer_not_to_say',
                            label: l10n.onboardingGenderPreferNotToSay,
                            icon: Icons.visibility_off,
                            selected:
                                _selectedGender == 'prefer_not_to_say',
                            onTap: () => setState(
                                () => _selectedGender = 'prefer_not_to_say'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(l10n.onboardingDetailsAgeRange, style: AppTypography.h4),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          'Menos de 18',
                          '18-24',
                          '25-34',
                          '35-44',
                          '45-54',
                          '55+',
                        ]
                            .map(
                              (range) => AgeRangeChip(
                                label: range,
                                selected: _selectedAgeRange == range,
                                onTap: () =>
                                    setState(() => _selectedAgeRange = range),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.xxl,
                ),
                child: BlocBuilder<OnboardingCubit, OnboardingState>(
                  builder: (context, state) {
                    return TortuPrimaryButton(
                      label: l10n.onboardingFinish,
                      onTap: _canFinish ? _onFinish : null,
                      isLoading: state is OnboardingLoading,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
