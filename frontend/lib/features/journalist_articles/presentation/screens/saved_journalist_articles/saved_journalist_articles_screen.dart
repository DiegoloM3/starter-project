import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/app_skeletons.dart';
import 'package:news_app_clean_architecture/config/theme/load_failure_message.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/config/theme/app_toasts.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/saved_journalist_articles/saved_journalist_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/saved_journalist_articles/saved_journalist_articles_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/journalist_article_tile.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/journalist_article_placeholders.dart';
import 'package:news_app_clean_architecture/core/constants/route_names.dart';

/// Placeholder articles drawn as a skeleton while the real ones are loading.
final List<JournalistArticleEntity> _loadingArticles = buildPlaceholderJournalistArticles(3);

/// The journalists' articles that the signed-in journalist saved, shown inside a tab of the Saved section.
class SavedJournalistArticlesScreen extends StatelessWidget {
  const SavedJournalistArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SavedJournalistArticlesCubit, SavedJournalistArticlesState>(
      listenWhen: (previous, current) =>
          current is SavedJournalistArticleRemoved || current is SavedJournalistArticleRemoveFailure,
      listener: _onArticleRemoved,
      builder: (context, state) {
        if (state is SavedJournalistArticlesSuccess) return _buildArticles(context, state.articles);
        if (state is SavedJournalistArticlesFailure) return _buildFailure(context);
        return AppSkeletonizer(child: _buildArticles(context, _loadingArticles));
      },
    );
  }

  void _onArticleRemoved(BuildContext context, SavedJournalistArticlesState state) {
    final toast = state is SavedJournalistArticleRemoveFailure
        ? const AppToast.error('The article could not be removed', description: 'Please try again.')
        : const AppToast.info('Removed from saved');
    showAppToast(context, toast);
  }

  Widget _buildArticles(BuildContext context, List<JournalistArticleEntity> articles) {
    final cubit = context.read<SavedJournalistArticlesCubit>();
    // The bottom padding keeps the last article above the translucent navigation bar.
    final padding = EdgeInsets.only(top: 8, bottom: MediaQuery.paddingOf(context).bottom + 8);
    return RefreshIndicator(
      onRefresh: cubit.loadSavedArticles,
      child: articles.isEmpty
          ? ListView(padding: padding, children: const [_NoSavedArticlesMessage()])
          : ListView.builder(
              padding: padding,
              itemCount: articles.length,
              itemBuilder: (context, index) => JournalistArticleTile(
                article: articles[index],
                onPressed: (article) => _onArticlePressed(context, article),
                onRemove: cubit.removeSavedArticle,
              ),
            ),
    );
  }

  Widget _buildFailure(BuildContext context) {
    return Center(
      child: LoadFailureMessage(
        message: 'Your saved articles could not be loaded.',
        onRetry: context.read<SavedJournalistArticlesCubit>().loadSavedArticles,
      ),
    );
  }

  /// When the journalist comes back, the list is read again, in case they removed the article there.
  Future<void> _onArticlePressed(BuildContext context, JournalistArticleEntity article) async {
    await Navigator.pushNamed(context, RouteNames.journalistArticleDetails, arguments: article);
    if (context.mounted) context.read<SavedJournalistArticlesCubit>().loadSavedArticles();
  }
}

class _NoSavedArticlesMessage extends StatelessWidget {
  const _NoSavedArticlesMessage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        'No saved articles yet. Tap the bookmark on a journalist\'s article to keep it here.',
        textAlign: TextAlign.center,
        style: TextStyle(color: context.palette.textSecondary),
      ),
    );
  }
}
