import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tortutip/config/routes/app_routes.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/search/presentation/bloc/search_cubit.dart';
import 'package:tortutip/features/search/presentation/bloc/search_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/search/presentation/widgets/category_result_card.dart';
import 'package:tortutip/shared/widgets/tortutip_chip.dart';
import 'package:tortutip/shared/widgets/tortutip_skeleton.dart';
import 'package:tortutip/features/search/presentation/widgets/recent_search_row.dart';
import 'package:tortutip/features/search/presentation/widgets/search_bar_widget.dart';
import 'package:tortutip/l10n/app_localizations.dart';
import 'package:tortutip/features/search/presentation/widgets/search_empty_state.dart';
import 'package:tortutip/features/search/presentation/widgets/search_skeleton.dart';
import 'package:tortutip/features/search/presentation/widgets/suggestion_row.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<SearchCubit>().loadInitial();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCancel() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            SearchBarWidget(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (query) {
                context.read<SearchCubit>().onQueryChanged(query);
              },
              onSubmitted: (query) {
                context.read<SearchCubit>().search(query);
              },
              onCancel: _onCancel,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return _buildInitialView(state);
                  }
                  if (state is SearchSuggesting) {
                    return _buildSuggestingView(state);
                  }
                  if (state is SearchLoading) {
                    return const SearchSkeleton();
                  }
                  if (state is SearchLoaded) {
                    return _buildResultsView(state);
                  }
                  if (state is SearchEmpty) {
                    return SearchEmptyState(
                      suggestedCategories: state.suggestedCategories,
                      onCategoryTap: (cat) =>
                          _onCategoryTap(context, cat),
                    );
                  }
                  if (state is SearchError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.message,
                                style: AppTypography.body,
                                textAlign: TextAlign.center),
                            const SizedBox(height: AppSpacing.lg),
                            TextButton(
                              onPressed: () {
                                final q = _controller.text.trim();
                                if (q.isNotEmpty) {
                                  context.read<SearchCubit>().search(q);
                                }
                              },
                              child: Text(
                                'Retry',
                                style: AppTypography.body
                                    .copyWith(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialView(SearchInitial state) {
    final l10n = AppLocalizations.of(context);
    if (state.recentSearches.isEmpty) {
      return Center(
        child: Text(
          l10n.searchStartSearching,
          style: AppTypography.subtitle,
        ),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Text(l10n.searchRecentSearches, style: AppTypography.label),
        ),
        ...state.recentSearches.map(
          (q) => RecentSearchRow(
            query: q,
            onTap: () {
              _controller.text = q;
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: q.length),
              );
              context.read<SearchCubit>().search(q);
            },
            onRemove: () => context.read<SearchCubit>().removeRecent(q),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestingView(SearchSuggesting state) {
    return ListView(
      children: state.suggestions
          .map(
            (s) => SuggestionRow(
              suggestion: s,
              query: state.query,
              onTap: (value) {
                _controller.text = value;
                context.read<SearchCubit>().search(value);
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildResultsView(SearchLoaded state) {
    return DefaultTabController(
      length: 2,
      initialIndex: state.activeTab.clamp(0, 1),
      child: Column(
        children: [
          _buildTabBar(state),
          if (state.activeTab == 0 && state.articles.isNotEmpty)
            _buildCategoryFilters(state),
          Expanded(
            child: TabBarView(
              children: [
                _buildArticlesTab(state),
                _buildCategoriesTab(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(SearchLoaded state) {
    return TabBar(
      onTap: (idx) => context.read<SearchCubit>().setTab(idx),
      labelStyle: AppTypography.label,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.transparent,
      dividerColor: AppColors.border,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: [
        Tab(text: AppLocalizations.of(context).searchTabArticles(state.articles.length)),
        Tab(text: AppLocalizations.of(context).searchTabCategories(state.categories.length)),
      ],
    );
  }

  Widget _buildCategoryFilters(SearchLoaded state) {
    final articleCategories = state.articles
        .map((a) => a.categoryId)
        .toSet()
        .toList();

    if (articleCategories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: [
            _filterChip('all', AppLocalizations.of(context).searchFilterAll, state.activeFilter),
            ...articleCategories.map(
              (catId) {
                final catName = state.categories
                    .firstWhere(
                      (c) => c.id == catId,
                      orElse: () => CategoryEntity(
                          id: catId, name: catId, description: '', iconUrl: ''),
                    )
                    .name;
                return _filterChip(catId, catName, state.activeFilter);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String value, String label, String activeFilter) {
    final isActive = activeFilter == value;
    return GestureDetector(
      onTap: () => context.read<SearchCubit>().setFilter(value),
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: isActive ? AppColors.textOnDark : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildArticlesTab(SearchLoaded state) {
    final l10n = AppLocalizations.of(context);
    final articles = state.filteredArticles;
    if (articles.isEmpty) {
      return Center(
        child: Text(l10n.searchNoArticles, style: AppTypography.subtitle),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: articles.length,
      itemBuilder: (_, index) {
        final article = articles[index];
        final catName = state.categories
            .firstWhere(
              (c) => c.id == article.categoryId,
              orElse: () => CategoryEntity(
                  id: '', name: '', description: '', iconUrl: ''),
            )
            .name;
        return _ArticleSearchRow(
          article: article,
          categoryName: catName,
          onTap: () => context.push(
            AppRoutes.articlePath(article.id),
            extra: article,
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab(SearchLoaded state) {
    final l10n = AppLocalizations.of(context);
    if (state.categories.isEmpty) {
      return Center(
        child: Text(l10n.searchNoCategories, style: AppTypography.subtitle),
      );
    }
    return ListView.builder(
      itemCount: state.categories.length,
      itemBuilder: (_, index) {
        final category = state.categories[index];
        return CategoryResultCard(
          category: category,
          articleCount: state.articles
              .where((a) => a.categoryId == category.id)
              .length,
          onTap: () => _onCategoryTap(context, category),
        );
      },
    );
  }

  void _onCategoryTap(BuildContext context, CategoryEntity category) {
    context.push(
      AppRoutes.exploreCategoryPath(category.id),
      extra: category,
    );
  }
}

class _ArticleSearchRow extends StatelessWidget {
  final ArticleEntity article;
  final String categoryName;
  final VoidCallback onTap;

  const _ArticleSearchRow({
    required this.article,
    required this.categoryName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = chipColorForCategoryName(categoryName);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: SizedBox(
                width: AppSpacing.thumbnailSm,
                height: AppSpacing.thumbnailSm,
                child: article.coverHorizontalUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: article.coverHorizontalUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => TortuSkeletonBox(
                          width: AppSpacing.thumbnailSm,
                          height: AppSpacing.thumbnailSm,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.textTertiary,
                            size: AppSpacing.iconSm,
                          ),
                        ),
                      )
                    : Container(color: AppColors.surface),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (categoryName.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: colors.$1,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        categoryName.toUpperCase(),
                        style: AppTypography.labelSm
                            .copyWith(color: colors.$2),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    article.title,
                    style:
                        AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (article.authorName.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      article.authorName,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
