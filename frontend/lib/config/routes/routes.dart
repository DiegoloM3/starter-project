import 'package:flutter/material.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/screens/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/screens/home/daily_news.dart';
import '../../features/daily_news/presentation/screens/publish_article/publish_article.dart';
import '../../features/daily_news/presentation/screens/saved_article/saved_article.dart';


class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _buildMaterialRoute(const DailyNews());

      case '/ArticleDetails':
        return _buildMaterialRoute(ArticleDetailsView(article: settings.arguments as ArticleEntity));

      case '/SavedArticles':
        return _buildMaterialRoute(const SavedArticles());

      case '/PublishArticle':
        return _buildMaterialRoute(const PublishArticleView());
        
      default:
        return _buildMaterialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _buildMaterialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
