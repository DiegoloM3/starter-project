import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tortutip/config/routes/app_routes.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_state.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/explore/presentation/bloc/category_list_cubit.dart';
import 'package:tortutip/features/explore/presentation/bloc/category_list_state.dart';
import 'package:tortutip/features/explore/presentation/widgets/article_list_card.dart';
import 'package:tortutip/l10n/app_localizations.dart';
import 'package:tortutip/shared/widgets/tortutip_app_bar.dart';
import 'package:tortutip/shared/widgets/tortutip_button.dart';
import 'package:tortutip/shared/widgets/tortutip_empty_view.dart';

class CategoryListScreen extends StatefulWidget {
  final CategoryEntity category;

  const CategoryListScreen({super.key, required this.category});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final userId =
        authState is AuthAuthenticated ? authState.user.id : '';
    context.read<CategoryListCubit>().loadCategory(widget.category, userId);
  }

  String get _userId {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.id : '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: TortuAppBar.detail(
        title: l10n.categoryListTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.categoryListSectionLabel,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  widget.category.name,
                  style: AppTypography.hero.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.category.description,
                  style:
                      AppTypography.body.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<CategoryListCubit, CategoryListState>(
              builder: (context, state) {
                if (state is CategoryListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CategoryListLoaded) {
                  return _buildList(context, state);
                }
                if (state is CategoryListLoadingMore) {
                  return _buildListWithLoader(context, state);
                }
                if (state is CategoryListEmpty) {
                  return TortuEmptyView(
                    icon: Icons.article_outlined,
                    title: l10n.categoryListEmpty,
                    subtitle: l10n.categoryListEmptySubtitle,
                  );
                }
                if (state is CategoryListError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, CategoryListLoaded state) {
    final articles = state.articles;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: articles.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == articles.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: TortuSecondaryButton(
                label: AppLocalizations.of(context).categoryListLoadMore,
                onTap: () => context
                    .read<CategoryListCubit>()
                    .loadMore(_userId),
              ),
            ),
          );
        }
        return _buildArticleCard(context, articles[index], state);
      },
    );
  }

  Widget _buildListWithLoader(
      BuildContext context, CategoryListLoadingMore state) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: state.articles.length + 1,
      separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == state.articles.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ArticleListCard(
          article: state.articles[index],
          category: state.category,
          isSaved: false,
          onTap: () => _onArticleTap(context, state.articles[index]),
          onBookmarkTap: () {},
        );
      },
    );
  }

  Widget _buildArticleCard(
      BuildContext context, ArticleEntity article, CategoryListLoaded state) {
    final isSaved = state.savedArticleIds.contains(article.id);
    return ArticleListCard(
      article: article,
      category: state.category,
      isSaved: isSaved,
      onTap: () => _onArticleTap(context, article),
      onBookmarkTap: () => context
          .read<CategoryListCubit>()
          .toggleBookmark(article.id, _userId),
      authorName: article.authorName,
      authorAvatarUrl: article.authorAvatarUrl,
    );
  }

  void _onArticleTap(BuildContext context, ArticleEntity article) {
    context.push(AppRoutes.articleDetailPath(article.id));
  }
}
