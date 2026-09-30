import 'package:flutter/material.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/screens/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/screens/home/daily_news.dart';
import '../../features/daily_news/presentation/screens/saved_article/saved_article.dart';
import '../../features/journalist_articles/domain/entities/published_article.dart';
import '../../features/journalist_articles/presentation/screens/publish_article/publish_article.dart';
import '../../features/journalist_articles/presentation/screens/published_article_detail/published_article_detail.dart';


class AppRoutes {
  static const String publishArticle = '/PublishArticle';
  static const String publishedArticleDetails = '/PublishedArticleDetails';

  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const DailyNews());

      case '/ArticleDetails':
        return _materialRoute(ArticleDetailsView(article: settings.arguments as ArticleEntity));

      case '/SavedArticles':
        return _materialRoute(const SavedArticles());

      case publishArticle:
        return _materialRoute(const PublishArticleView());

      case publishedArticleDetails:
        return _materialRoute(PublishedArticleDetailView(article: settings.arguments as PublishedArticleEntity));

      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
