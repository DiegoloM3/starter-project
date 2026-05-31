import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/profile/user_profile_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/search/search_screen.dart';

/// Path constants and route configuration for the daily news / articles feature.
///
/// Follows modular routing pattern where each feature defines its own routes.
/// Uses extension methods for type-safe, decoupled navigation between features.
abstract final class ArticleRoutes {
  ArticleRoutes._();

  // ══════════════════════════════════════════════════════════════════
  // Path Constants
  // ══════════════════════════════════════════════════════════════════

  static const String feed = '/';
  static const String articleDetail = '/article/:id';
  static const String search = '/search';
  static const String profile = '/profile';

  // ══════════════════════════════════════════════════════════════════
  // Path Builders
  // ══════════════════════════════════════════════════════════════════

  static String articleDetailPath(String id) => '/article/$id';

  // ══════════════════════════════════════════════════════════════════
  // Route Configuration
  // ══════════════════════════════════════════════════════════════════

  /// Top-level routes with absolute paths.
  ///
  /// [serviceLocator] resolves BLoC instances for pages that require DI.
  /// [authGuard] protects routes that require authentication.
  static List<RouteBase> getRoutes({
    required GetIt serviceLocator,
    String? Function(BuildContext, GoRouterState)? authGuard,
  }) {
    return [
      GoRoute(
        path: feed,
        name: 'feed',
        builder: (_, _) => BlocProvider(
          create: (_) =>
              serviceLocator<RemoteArticlesBloc>()..add(const GetArticles()),
          child: const DailyNews(),
        ),
      ),
      GoRoute(
        path: search,
        name: 'search',
        builder: (_, _) => const SearchScreen(),
      ),
    ];
  }

  /// Overlay routes nested as sub-routes of a parent branch using relative paths.
  ///
  /// When nested under feed at '/', `go()` builds a declarative stack
  /// (feed → overlay) enabling back navigation via Navigator.canPop.
  ///
  /// [parentNavigatorKey] renders these full-screen on the root navigator
  /// (no bottom nav), following the same pattern as [AuthRoutes.getRoutes].
  static List<RouteBase> getOverlayRoutes({
    required GetIt serviceLocator,
    GlobalKey<NavigatorState>? parentNavigatorKey,
    String? Function(BuildContext, GoRouterState)? authGuard,
  }) {
    return [
      GoRoute(
        path: 'article/:id',
        name: 'articleDetail',
        parentNavigatorKey: parentNavigatorKey,
        builder: (_, state) =>
            ArticleDetailsView(article: state.extra as ArticleEntity?),
      ),
      GoRoute(
        path: 'search',
        name: 'search',
        parentNavigatorKey: parentNavigatorKey,
        builder: (_, _) => const SearchScreen(),
      ),
      GoRoute(
        path: 'profile',
        name: 'profile',
        parentNavigatorKey: parentNavigatorKey,
        redirect: authGuard,
        builder: (_, _) => const UserProfileScreen(),
      ),
    ];
  }

  /// Article detail sub-route for nesting under secondary branches
  /// (bookmarks, community). Uses relative path and **no route name**
  /// to avoid conflicts with the primary named route under feed.
  ///
  /// Enables tab-aware back navigation: going back from a detail page
  /// returns to the originating tab instead of always going to feed.
  static List<RouteBase> getDetailRoutes({
    GlobalKey<NavigatorState>? parentNavigatorKey,
  }) {
    return [
      GoRoute(
        path: 'article/:id',
        parentNavigatorKey: parentNavigatorKey,
        builder: (_, state) =>
            ArticleDetailsView(article: state.extra as ArticleEntity?),
      ),
    ];
  }
}

// ══════════════════════════════════════════════════════════════════
// Navigation Extensions
// ══════════════════════════════════════════════════════════════════

/// Extension for type-safe navigation to article screens.
///
/// This pattern eliminates string-based navigation and reduces coupling.
/// Features can navigate to articles without knowing internal route paths.
///
/// Example:
/// ```dart
/// // Instead of: context.go('/article/123')
/// context.goToArticleDetail('123', article: myArticle);
/// ```
extension ArticleNavigation on BuildContext {
  /// Navigate to feed page.
  void goToFeed() => go(ArticleRoutes.feed);

  /// Navigate to article detail page.
  ///
  /// **Context-aware:** Builds the URL relative to the current tab so that
  /// back navigation returns to the originating branch (feed, bookmarks,
  /// or community) instead of always going to feed.
  void goToArticleDetail(String id, {ArticleEntity? article}) {
    final base = _currentBranchBase;
    go('$base/article/$id', extra: article);
  }

  /// Navigate to search page.
  void goToSearch() => go(ArticleRoutes.search);

  /// Navigate to user profile page.
  void goToProfile() => go(ArticleRoutes.profile);

  // ── Helpers ──────────────────────────────────────────────────

  /// Returns the base path of the current shell branch so that
  /// sub-route navigation stays within the same tab.
  String get _currentBranchBase {
    final location = GoRouterState.of(this).matchedLocation;
    if (location.startsWith('/bookmarks')) return '/bookmarks';
    if (location.startsWith('/community')) return '/community';
    return ''; // feed is at '/'
  }
}
