import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/article_search/article_search_screen.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/screens/user_article_detail/user_article_detail_screen.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/screens/user_articles_list/user_articles_list_screen.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/screens/upload_user_article/upload_user_article_screen.dart';

import '../../features/daily_news/domain/entities/article_entity.dart';
import '../../features/daily_news/presentation/screens/article_detail/daily_news_article_detail_screen.dart';
import '../../features/daily_news/presentation/screens/daily_news_list/daily_news_list_screen.dart';
import '../../features/daily_news/presentation/screens/saved_article_list/saved_article_list_screen.dart';

class AppRouter {
  late final GoRouter router;

  factory AppRouter() => _instance;

  static final AppRouter _instance = AppRouter._internal();

  static const String dailyNews = '/dailyNews';
  static const String userArticleDetails = '/userArticleDetails';
  static const String dailyNewsArticleDetail = '/dailyNewsArticleDetail';
  static const String savedArticles = '/savedArticles';
  static const String uploadUserArticle = '/uploadUserArticle';
  static const String userArticles = '/userArticles';
  static const articleSearch = '/article-search';

  AppRouter._internal() {
    router = GoRouter(
      initialLocation: dailyNews,
      routes: [
        _dailyNews(),
        _userArticleDetailsView(),
        _dailyNewsArticleDetail(),
        _savedArticles(),
        _uploadArticle(),
        _myArticles(),
        _articleSearch()
      ],
    );
  }

  GoRoute _articleSearch() {
    return GoRoute(
      path: articleSearch,
      builder: (context, state) =>
          ArticleSearchScreen(articles: state.extra as List<ArticleEntity>),
    );
  }

  GoRoute _dailyNews() {
    return GoRoute(
      path: dailyNews,
      builder: (context, state) => const DailyNewsListScreen(),
    );
  }

  GoRoute _userArticleDetailsView() {
    return GoRoute(
      path: userArticleDetails,
      builder: (context, state) => UserArticleDetailScreen(
        article: state.extra as UserArticleEntity,
      ),
    );
  }

  GoRoute _dailyNewsArticleDetail() {
    return GoRoute(
      path: dailyNewsArticleDetail,
      builder: (context, state) => DailyNewsArticleDetailScreen(
        article: state.extra as ArticleEntity,
      ),
    );
  }

  GoRoute _savedArticles() {
    return GoRoute(
      path: savedArticles,
      builder: (context, state) => const SavedArticlesListScreen(),
    );
  }

  GoRoute _uploadArticle() {
    return GoRoute(
      path: uploadUserArticle,
      builder: (context, state) => const UploadUserArticleScreen(),
    );
  }

  GoRoute _myArticles() {
    return GoRoute(
      path: userArticles,
      builder: (context, state) => const UserArticlesListScreen(),
    );
  }
}
