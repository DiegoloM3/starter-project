import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/theme/app_skeletons.dart';
import '../../../../../config/theme/app_themes.dart';
import '../../../../../config/theme/app_toasts.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';
import '../../widgets/article_tile.dart';
import '../../widgets/article_placeholders.dart';
import 'package:news_app_clean_architecture/core/constants/route_names.dart';

/// Placeholder articles drawn as a skeleton while the real ones are loading.
final List<ArticleEntity> _loadingArticles = buildPlaceholderArticles(3);

/// The news saved on the phone: the "Daily News" tab of the Saved section, which the app navigation builds
/// with the [LocalArticlesBloc].
class SavedArticlesScreen extends StatelessWidget {
  const SavedArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) => _buildSavedNews();

  Widget _buildSavedNews() {
    return BlocBuilder<LocalArticlesBloc, LocalArticlesState>(
      builder: (context, state) {
        if (state is LocalArticlesLoading) {
          return AppSkeletonizer(child: _buildArticlesList(context, _loadingArticles));
        } else if (state is LocalArticlesError) {
          return const Center(child: Icon(Icons.refresh));
        } else if (state is LocalArticlesDone) {
          return _buildArticlesList(context, state.articles!);
        }
        return Container();
      },
    );
  }

  Widget _buildArticlesList(BuildContext context, List<ArticleEntity> articles) {
    if (articles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No saved news yet. Tap the bookmark on a news article to keep it here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.palette.textSecondary),
        ),
      );
    }

    // The bottom padding keeps the last article above the translucent navigation bar.
    return ListView.builder(
      padding: EdgeInsets.only(top: 8, bottom: MediaQuery.paddingOf(context).bottom + 8),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        return ArticleTile(
          article: articles[index],
          onRemove: (article) => _onRemoveArticle(context, article),
          onArticlePressed: (article) => _onArticlePressed(context, article),
        );
      },
    );
  }

  void _onRemoveArticle(BuildContext context, ArticleEntity article) {
    BlocProvider.of<LocalArticlesBloc>(context).add(RemoveArticle(article));
    showAppToast(context, const AppToast.info('Removed from saved'));
  }

  /// When the journalist comes back, the list is read again, in case they removed the article there.
  Future<void> _onArticlePressed(BuildContext context, ArticleEntity article) async {
    final localArticleBloc = BlocProvider.of<LocalArticlesBloc>(context);
    await Navigator.pushNamed(context, RouteNames.articleDetails, arguments: article);
    localArticleBloc.add(const GetSavedArticles());
  }
}
