import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/utils/format_date_util.dart';
import 'package:news_app_clean_architecture/shared/widgets/article/article_details_widget.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/user_articles_list/user_articles_bloc.dart';

class UserArticleDetailScreen extends StatelessWidget {
  final UserArticleEntity article;
  const UserArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<UserArticlesBloc>(),
      child: Builder(
        builder: (context) => ArticleDetailsWidget(
          title: article.title,
          imageUrl: article.thumbnailUrl,
          description: article.content,
          dateText: formatDateUtil(article.publishedAt),
          onDelete: () => _deleteArticle(context),
        ),
      ),
    );
  }

  void _deleteArticle(BuildContext context) {
    context.read<UserArticlesBloc>().add(DeleteUserArticle(article: article));
  }
}