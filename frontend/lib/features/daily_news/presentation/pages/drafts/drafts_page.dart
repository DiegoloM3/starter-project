import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/drafts/drafts_list_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/drafts/drafts_list_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/drafts/drafts_list_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../../config/theme/app_themes.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/skeleton_article_tile.dart';

class DraftsPage extends StatelessWidget {
  const DraftsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId =
        authState is AuthAuthenticated ? authState.user!.uid : '';

    return BlocProvider<DraftsListBloc>(
      create: (_) =>
          sl<DraftsListBloc>()..add(DraftsSubscriptionRequested(userId)),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: _buildAppBar(context),
        body: const _DraftsBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left, color: AppColors.t1, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppLocalizations.of(context)!.myDrafts,
        style: AppTypography.serif(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.t1,
          letterSpacing: -0.2,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }
}

class _DraftsBody extends StatelessWidget {
  const _DraftsBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<DraftsListBloc, DraftsListState>(
      builder: (context, state) {
        if (state is DraftsListLoading) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (_, i) => SkeletonArticleTile(showDivider: i < 4),
          );
        }

        if (state is DraftsListFailure) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: l10n.somethingWentWrong,
            subtitle:
                state.error?.message ?? l10n.failedToLoadDrafts,
            actionLabel: l10n.tryAgain,
            onAction: () {
              final retryAuthState = context.read<AuthBloc>().state;
              final uid = retryAuthState is AuthAuthenticated
                  ? retryAuthState.user!.uid
                  : '';
              context
                  .read<DraftsListBloc>()
                  .add(DraftsSubscriptionRequested(uid));
            },
          );
        }

        if (state is DraftsListDone) {
          final articles = state.articles ?? [];

          if (articles.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.edit_note,
              title: l10n.noDraftsTitle,
              subtitle: l10n.noDraftsSubtitle,
              actionLabel: l10n.writeAnArticle,
              onAction: () =>
                  Navigator.pushNamed(context, '/CreateArticle'),
            );
          }

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Dismissible(
                key: ValueKey(article.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: AppColors.error,
                  child: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 22),
                ),
                confirmDismiss: (_) => _confirmDelete(context),
                onDismissed: (_) => _onDismissed(context, article),
                child: ArticleWidget(
                  article: article,
                  showStatus: true,
                  showReadingTime: true,
                  showDivider: index < articles.length - 1,
                  onArticlePressed: (a) {
                    Navigator.pushNamed(
                      context,
                      '/CreateArticle',
                      arguments: a,
                    );
                  },
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _onDismissed(BuildContext context, ArticleEntity article) {
    if (article.id != null) {
      context.read<DraftsListBloc>().add(DraftDeleted(article.id!));
    }
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.draftDeleted),
        action: SnackBarAction(
          label: l10n.undo,
          textColor: AppColors.red,
          onPressed: () {
            // Re-subscribe to refresh the list (undo is approximate —
            // the draft was already deleted server-side).
            final retryAuthState = context.read<AuthBloc>().state;
            final uid = retryAuthState is AuthAuthenticated
                ? retryAuthState.user!.uid
                : '';
            context
                .read<DraftsListBloc>()
                .add(DraftsSubscriptionRequested(uid));
          },
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              l10n.deleteDraft,
              style: AppTypography.serif(fontSize: 18),
            ),
            content: Text(
              l10n.deleteDraftConfirmation,
              style: AppTypography.sans(
                fontSize: 13,
                color: AppColors.t2,
                height: 1.55,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  l10n.cancel,
                  style: AppTypography.sans(color: AppColors.t2),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: Text(
                  l10n.delete,
                  style: AppTypography.sans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
