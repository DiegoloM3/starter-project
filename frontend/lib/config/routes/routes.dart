import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';
import '../../features/publish_article/presentation/cubit/publish_article_cubit.dart';
import '../../features/publish_article/domain/entities/publishable_article.dart';
import '../../features/publish_article/presentation/cubit/published_articles_cubit.dart';
import '../../features/publish_article/presentation/pages/publish_article_page.dart';
import '../../features/publish_article/presentation/pages/published_article_detail_page.dart';
import '../../features/publish_article/presentation/pages/published_articles_page.dart';
import '../../features/publish_article/domain/repository/article_image_picker.dart';
import '../../injection_container.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const DailyNews());

      case '/ArticleDetails':
        return _materialRoute(
          ArticleDetailsView(
            article: settings.arguments as ArticleEntity,
          ),
        );

      case '/SavedArticles':
        return _materialRoute(const SavedArticles());

      case '/PublishArticle':
        return _materialRoute(
          BlocProvider<PublishArticleCubit>(
            create: (_) => sl<PublishArticleCubit>(),
            child: PublishArticlePage(imagePicker: sl<ArticleImagePicker>()),
          ),
        );

      case '/PublishedArticles':
        return _materialRoute(
          BlocProvider<PublishedArticlesCubit>(
            create: (_) => sl<PublishedArticlesCubit>()..load(),
            child: const PublishedArticlesPage(),
          ),
        );

      case '/PublishedArticleDetails':
        return _materialRoute(
          PublishedArticleDetailPage(
            article: settings.arguments as PublishableArticle,
          ),
        );

      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
