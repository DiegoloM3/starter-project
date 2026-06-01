import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tortutip/config/routes/app_routes.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_state.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/explore/presentation/bloc/explore_cubit.dart';
import 'package:tortutip/features/explore/presentation/bloc/explore_state.dart';
import 'package:tortutip/features/explore/presentation/widgets/category_card.dart';
import 'package:tortutip/features/explore/presentation/widgets/streak_card.dart';
import 'package:tortutip/l10n/app_localizations.dart';
import 'package:tortutip/shared/widgets/tortutip_app_bar.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _isVisible = false;

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    context.read<ExploreCubit>().loadExplore(user: user);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final location = GoRouterState.of(context).matchedLocation;
      final nowVisible = location == AppRoutes.explore;
      if (nowVisible && !_isVisible) {
        _loadData();
      }
      _isVisible = nowVisible;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TortuAppBar(
        title: 'TortuTip',
        avatarUrl: context.select<AuthBloc, String?>(
          (b) => b.state is AuthAuthenticated
              ? (b.state as AuthAuthenticated).user.avatarUrl
              : null,
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => curr is AuthAuthenticated,
        listener: (context, state) => _loadData(),
        child: BlocBuilder<ExploreCubit, ExploreState>(
        builder: (context, state) {
          if (state is ExploreLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ExploreLoaded) {
            return _buildLoaded(context, state);
          }
          if (state is ExploreError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, ExploreLoaded state) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.floatingTabBarClearance),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchBar(),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              l10n.exploreKaiaTitle,
              style: AppTypography.h2.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          StreakCard(
            streakDays: state.streakDays,
            categoryProgress: state.categoryProgress,
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              l10n.exploreCategoriesTitle,
              style: AppTypography.h2.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.0,
              ),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return CategoryCard(
                  category: category,
                  onTap: () => _onCategoryTap(context, category),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.floatingTabBarClearance),
        ],
      ),
    );
  }

  void _onCategoryTap(BuildContext context, CategoryEntity category) {
    context
        .push(
          AppRoutes.exploreCategoryPath(category.id),
          extra: category,
        )
        .then((_) => _loadData());
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.search),
      child: AbsorbPointer(
        child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppLocalizations.of(context).exploreSearchHint,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
