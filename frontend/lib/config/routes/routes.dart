import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/bloc/article/create/create_article_state.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/article_preview/article_preview_page.dart';
import '../../features/daily_news/presentation/pages/create_article/create_article_page.dart';
import '../../features/daily_news/presentation/pages/drafts/drafts_page.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/my_articles/my_articles_page.dart';
import '../../features/daily_news/presentation/pages/route_not_found_page.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';
import '../../features/daily_news/presentation/pages/search/search_page.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const DailyNews());

      case '/Login':
        return _materialRoute(const LoginPage());

      case '/Register':
        return _materialRoute(const RegisterPage());

      case '/ArticleDetails':
        final article = settings.arguments is ArticleEntity
            ? settings.arguments as ArticleEntity
            : null;
        return _materialRoute(ArticleDetailsView(article: article));

      case '/SavedArticles':
        return _materialRoute(const SavedArticles());

      case '/CreateArticle':
        final draft = settings.arguments is ArticleEntity
            ? settings.arguments as ArticleEntity
            : null;
        return _materialRoute(CreateArticlePage(draft: draft));

      case '/ArticlePreview':
        if (settings.arguments is! CreateArticleState) {
          return _materialRoute(RouteNotFoundPage(routeName: settings.name));
        }
        return _materialRoute(ArticlePreviewPage(
          articleState: settings.arguments as CreateArticleState,
        ));

      case '/Drafts':
        return _materialRoute(const DraftsPage());

      case '/Search':
        return _materialRoute(const SearchPage());

      case '/MyArticles':
        return _materialRoute(const MyArticlesPage());

      case '/EditArticle':
        final draft = settings.arguments is ArticleEntity
            ? settings.arguments as ArticleEntity
            : null;
        return _materialRoute(CreateArticlePage(draft: draft));

      default:
        assert(false, 'Unknown route: ${settings.name}');
        return _materialRoute(RouteNotFoundPage(routeName: settings.name));
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
