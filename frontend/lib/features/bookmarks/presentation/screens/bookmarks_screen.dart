import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tortutip/config/routes/app_routes.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/shared/widgets/tortutip_empty_view.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_state.dart';
import 'package:tortutip/features/bookmarks/presentation/bloc/bookmarks_cubit.dart';
import 'package:tortutip/features/bookmarks/presentation/bloc/bookmarks_state.dart';
import 'package:tortutip/l10n/app_localizations.dart';
import 'package:tortutip/shared/widgets/tortutip_app_bar.dart';
import 'package:tortutip/shared/widgets/tortutip_article_list_card.dart';
import 'package:tortutip/shared/widgets/tortutip_button.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarksCubit>().loadBookmarks(_userId(context));
    });
  }

  String _userId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) return authState.user.id;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: TortuAppBar(
        title: l10n.bookmarksTitle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<BookmarksCubit, BookmarksState>(
        builder: (context, state) {
          if (state is BookmarksInitial) return const SizedBox.shrink();
          if (state is BookmarksLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookmarksEmpty) {
            return TortuEmptyView(
              icon: Icons.bookmark_border,
              title: l10n.bookmarksEmpty,
              subtitle: l10n.bookmarksEmptySubtitle,
              actionLabel: l10n.bookmarksExploreAction,
              onActionTap: () => context.go(AppRoutes.feed),
            );
          }
          if (state is BookmarksLoaded) return _buildList(context, state);
          if (state is BookmarksError) return _buildError(context, state.message);
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, BookmarksLoaded state) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.bookmarksSectionLabel,
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.bookmarksSectionTitle,
                style: AppTypography.hero.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                l10n.bookmarksSectionSubtitle,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async =>
                context.read<BookmarksCubit>().loadBookmarks(_userId(context)),
            child: ListView.separated(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.md,
                bottom: AppSpacing.floatingTabBarClearance,
              ),
              itemCount: state.articles.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, index) {
                if (index == state.articles.length) {
                  return _buildLoadMoreButton(context);
                }
                return _buildArticleCard(context, state.articles[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: TortuSecondaryButton(
          label: AppLocalizations.of(context).bookmarksLoadMore,
          onTap: () =>
              context.read<BookmarksCubit>().loadMore(_userId(context)),
        ),
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, ArticleEntity article) {
    return TortuArticleListCard(
      article: article,
      isSaved: true,
      onTap: () => context.push(AppRoutes.articleDetailPath(article.id)),
      onBookmarkTap: () => _onUnsave(context, article),
    );
  }

  void _onUnsave(BuildContext context, ArticleEntity article) {
    final cubit = context.read<BookmarksCubit>();
    cubit.unsaveArticle(_userId(context), article.id);
    final l10n2 = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n2.bookmarksRemoved),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: l10n2.bookmarksUndo,
          onPressed: () => cubit.loadBookmarks(_userId(context)),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            TortuPrimaryButton(
              label: AppLocalizations.of(context).bookmarksRetry,
              onTap: () => context
                  .read<BookmarksCubit>()
                  .loadBookmarks(_userId(context)),
            ),
          ],
        ),
      ),
    );
  }
}
