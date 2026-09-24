import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/bloc/upload_article/upload_article_cubit.dart';
import '../../features/daily_news/presentation/bloc/edit_article/edit_article_cubit.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';
import '../../features/daily_news/presentation/pages/upload_article_screen.dart';
import '../../features/daily_news/presentation/pages/edit_article_screen.dart';
import '../../features/daily_news/presentation/pages/user_articles_screen.dart';
import '../../injection_container.dart';

class EditArticleScreenArgs {
  final String articleId;
  final String initialTitle;
  final String initialContent;
  final String initialAuthor;
  final String? initialDescription;
  final String? initialCategory;
  final String? initialThumbnailPath;

  EditArticleScreenArgs({
    required this.articleId,
    required this.initialTitle,
    required this.initialContent,
    required this.initialAuthor,
    this.initialDescription,
    this.initialCategory,
    this.initialThumbnailPath,
  });
}

class AppRoutes {
  static const String home = '/';
  static const String articleDetails = '/article-details';
  static const String savedArticles = '/saved-articles';
  static const String uploadArticle = '/upload-article';
  static const String editArticle = '/edit-article';
  static const String userArticles = '/user-articles';

  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _materialRoute(const DailyNews());

      case articleDetails:
        return _materialRoute(
          ArticleDetailsView(article: settings.arguments as ArticleEntity),
        );

      case savedArticles:
        return _materialRoute(const SavedArticles());

      case uploadArticle:
        return _materialRoute(
          BlocProvider<UploadArticleCubit>(
            create: (context) => sl<UploadArticleCubit>(),
            child: const UploadArticleScreen(),
          ),
        );

      case editArticle:
        final args = settings.arguments as EditArticleScreenArgs?;
        if (args == null) {
          return _materialRoute(const DailyNews());
        }
        return _materialRoute(
          BlocProvider<EditArticleCubit>(
            create: (context) => sl<EditArticleCubit>(),
            child: EditArticleScreen(
              articleId: args.articleId,
              initialTitle: args.initialTitle,
              initialContent: args.initialContent,
              initialAuthor: args.initialAuthor,
              initialDescription: args.initialDescription,
              initialCategory: args.initialCategory,
              initialThumbnailPath: args.initialThumbnailPath,
            ),
          ),
        );

      case userArticles:
        final userId = settings.arguments as String?;
        if (userId == null) {
          return _materialRoute(const DailyNews());
        }
        return _materialRoute(UserArticlesScreen(userId: userId));

      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
