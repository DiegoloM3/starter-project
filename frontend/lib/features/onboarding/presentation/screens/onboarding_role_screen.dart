import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tortutip/config/routes/app_routes.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:tortutip/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:tortutip/features/onboarding/presentation/widgets/role_card.dart';
import 'package:tortutip/l10n/app_localizations.dart';
import 'package:tortutip/shared/widgets/tortutip_button.dart';
import 'package:tortutip/shared/widgets/tortutip_progress_dots.dart';

class OnboardingRoleScreen extends StatefulWidget {
  const OnboardingRoleScreen({super.key});

  @override
  State<OnboardingRoleScreen> createState() => _OnboardingRoleScreenState();
}

class _OnboardingRoleScreenState extends State<OnboardingRoleScreen> {
  String? _selectedRole;

  void _onNext() {
    final userId = context.read<OnboardingCubit>().currentUser?.id;
    if (userId == null) return;
    context.read<OnboardingCubit>().selectRole(userId, _selectedRole!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingRoleSelected) {
          context.go(AppRoutes.onboardingDetails);
        } else if (state is OnboardingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const TortuProgressDots(total: 3, current: 1),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  '¿Cómo quieres participar?',
                  style: AppTypography.h1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                RoleCard(
                  role: 'writer',
                  label: l10n.onboardingRoleWriter,
                  description: 'Crea contenido y ayuda a la comunidad.',
                  selected: _selectedRole == 'writer',
                  onTap: () => setState(() => _selectedRole = 'writer'),
                  icon: Icons.edit_note,
                  iconBackgroundColor: AppColors.writerAccent,
                ),
                const SizedBox(height: AppSpacing.md),
                RoleCard(
                  role: 'reader',
                  label: l10n.onboardingRoleReader,
                  description: 'Descubre ideas para mejorar tu día a día.',
                  selected: _selectedRole == 'reader',
                  onTap: () => setState(() => _selectedRole = 'reader'),
                  icon: Icons.menu_book,
                  iconBackgroundColor: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Puedes cambiar esto después',
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                BlocBuilder<OnboardingCubit, OnboardingState>(
                  builder: (context, state) {
                    return TortuPrimaryButton(
                      label: l10n.onboardingNext,
                      onTap: _selectedRole == null ? null : _onNext,
                      isLoading: state is OnboardingLoading,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
