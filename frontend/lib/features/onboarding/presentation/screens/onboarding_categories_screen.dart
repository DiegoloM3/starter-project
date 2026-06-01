import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tortutip/config/routes/app_routes.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/categories/presentation/bloc/category_cubit.dart';
import 'package:tortutip/features/categories/presentation/bloc/category_state.dart';
import 'package:tortutip/features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:tortutip/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:tortutip/features/onboarding/presentation/widgets/category_card.dart';
import 'package:tortutip/injection/injection_container.dart';
import 'package:tortutip/l10n/app_localizations.dart';
import 'package:tortutip/shared/widgets/tortutip_button.dart';
import 'package:tortutip/shared/widgets/tortutip_progress_dots.dart';

class OnboardingCategoriesScreen extends StatefulWidget {
  const OnboardingCategoriesScreen({super.key});

  @override
  State<OnboardingCategoriesScreen> createState() =>
      _OnboardingCategoriesScreenState();
}

class _OnboardingCategoriesScreenState
    extends State<OnboardingCategoriesScreen> {
  final Set<String> _selectedCategoryIds = {};

  void _onNext() {
    final userId = context.read<OnboardingCubit>().currentUser?.id;
    if (userId == null) return;
    context
        .read<OnboardingCubit>()
        .selectCategories(userId, _selectedCategoryIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<CategoryCubit>()..loadCategories(),
      child: BlocListener<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingComplete) {
            context.go(AppRoutes.onboardingRole);
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
                      const TortuProgressDots(total: 3, current: 0),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(l10n.onboardingCategoriesTitle, style: AppTypography.h1),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.onboardingCategoriesSubtitle,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: BlocBuilder<CategoryCubit, CategoryState>(
                      builder: (context, state) {
                        if (state is CategoryLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state is CategoryError) {
                          return Center(child: Text(state.message));
                        }
                        if (state is CategoryLoaded) {
                          return GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: AppSpacing.sm,
                            mainAxisSpacing: AppSpacing.sm,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: state.categories
                                .map(
                                  (cat) => CategoryCard(
                                    category: cat,
                                    selected:
                                        _selectedCategoryIds.contains(cat.id),
                                    onTap: () {
                                      setState(() {
                                        if (_selectedCategoryIds
                                            .contains(cat.id)) {
                                          _selectedCategoryIds.remove(cat.id);
                                        } else {
                                          _selectedCategoryIds.add(cat.id);
                                        }
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BlocBuilder<OnboardingCubit, OnboardingState>(
                    builder: (context, state) {
                      return TortuPrimaryButton(
                        label: l10n.onboardingNext,
                        onTap:
                            _selectedCategoryIds.isEmpty ? null : _onNext,
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
      ),
    );
  }
}
