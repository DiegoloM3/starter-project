import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/community_articles/domain/entities/community_article.dart';
import '../../features/community_articles/presentation/bloc/community_article_lookup_cubit.dart';
import '../../features/community_articles/presentation/bloc/social_interactions_cubit.dart';
import '../../features/community_articles/presentation/screens/community_article_deep_link_screen.dart';
import '../../features/community_articles/presentation/bloc/publish_article_cubit.dart';
import '../../features/community_articles/presentation/screens/community_article_detail_screen.dart';
import '../../features/community_articles/presentation/screens/publish_article_screen.dart';
import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';
import '../../injection_container.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoutes(RouteSettings settings) {
    // Flutter preserves query parameters in the initial route name (for
    // example, `/?article=abc`). Resolve the shared article before matching
    // the exact path so deep links do not fall through to the home route.
    final sharedArticleId = _articleIdFrom(settings.name);
    if (sharedArticleId != null) {
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              sl<CommunityArticleLookupCubit>(param1: sharedArticleId)..load(),
          child: const CommunityArticleDeepLinkScreen(),
        ),
      );
    }

    switch (settings.name) {
      case '/':
        return _materialRoute(const DailyNews());
      case '/ArticleDetails':
        return _materialRoute(
          ArticleDetailsView(article: settings.arguments as ArticleEntity),
        );
      case '/CommunityArticleDetails':
        final article = settings.arguments as CommunityArticleEntity;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<SocialInteractionsCubit>(param1: article.id),
            child: CommunityArticleDetailScreen(article: article),
          ),
        );
      case '/SavedArticles':
        return _materialRoute(const SavedArticles());
      case '/Auth':
        return _materialRoute(const AuthScreen());
      case '/PublishArticle':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<PublishArticleCubit>(),
            child: const PublishArticleScreen(),
          ),
        );
      default:
        return _materialRoute(const DailyNews());
    }
  }

  static String? _articleIdFrom(String? routeName) {
    if (routeName == null) return null;
    final uri = Uri.tryParse(routeName);
    final value = uri?.queryParameters['article']?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
