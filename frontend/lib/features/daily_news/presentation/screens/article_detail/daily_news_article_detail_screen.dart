import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/shared/widgets/article/article_details_widget.dart';

class DailyNewsArticleDetailScreen extends StatelessWidget {
  final ArticleEntity article;
  const DailyNewsArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<LocalArticleBloc>()..add(const GetSavedArticles()),
      child: BlocBuilder<LocalArticleBloc, LocalArticlesState>(
        builder: _buildDetails,
      ),
    );
  }

  Widget _buildDetails(BuildContext context, LocalArticlesState state) {
    final isSaved = _isArticleSaved(state);
    return ArticleDetailsWidget(
      title: article.title ?? '',
      imageUrl: article.urlToImage ?? '',
      description: '${article.description ?? ''}\n\n${article.content ?? ''}',
      dateText: article.publishedAt ?? '',
      isSaved: isSaved,
      onSave: () => _toggleSave(context, isSaved),
    );
  }

  bool _isArticleSaved(LocalArticlesState state) {
    return state is LocalArticlesDone && state.articles.any((saved) => saved.url == article.url);
  }

  void _toggleSave(BuildContext context, bool isSaved) {
    if (isSaved) {
      context.read<LocalArticleBloc>().add(RemoveArticle(article: article));
    } else {
      context.read<LocalArticleBloc>().add(SaveArticle(article: article));
    }
    _showSaveSnackbar(context, isSaved);
  }

  void _showSaveSnackbar(BuildContext context, bool wasSaved) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(wasSaved ? 'Artículo quitado de guardados.' : 'Artículo guardado exitosamente.'),
      ),
    );
  }
}