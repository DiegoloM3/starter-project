import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/routes/auth_routes.dart';
import 'package:news_app_clean_architecture/features/bookmarks/routes/bookmark_routes.dart';
import 'package:news_app_clean_architecture/features/community_articles/routes/community_routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/routes/article_routes.dart';
import 'package:news_app_clean_architecture/config/router/widgets/main_scaffold.dart';

import 'auth_route_guard.dart';
import 'go_router_refresh_stream.dart';

/// Application router configuration using go_router.
///
/// Uses StatefulShellRoute for bottom navigation with three tabs:
/// Feed, Bookmarks, and My Posts. Each tab preserves its own state.
///
/// **Key Features:**
/// - Singleton pattern for centralized router configuration
/// - StatefulShellRoute for persistent bottom navigation
/// - Automatic refresh on auth state changes via GoRouterRefreshStream
/// - Modular route composition from feature packages
/// - Reusable auth guards for protected routes
/// - Global redirect logic for authentication flow
class AppRouter {
  AppRouter._();

  static final AppRouter _instance = AppRouter._();

  /// Get the singleton instance.
  static AppRouter get instance => _instance;

  /// The configured GoRouter instance.
  late final GoRouter router;

  /// Stream adapter for router refresh on auth changes.
  GoRouterRefreshStream? _refreshStream;

  /// Navigation keys for nested navigators.
  final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'root',
  );
  final GlobalKey<NavigatorState> _feedNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'feed',
  );
  final GlobalKey<NavigatorState> _communityNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'community');
  final GlobalKey<NavigatorState> _bookmarksNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'bookmarks');
  final GlobalKey<NavigatorState> _editorNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'editor');

  /// Initialize router by consolidating all feature routes.
  ///
  /// The [authBloc] parameter ensures the router listens to the same
  /// AuthBloc instance used by the widget tree, avoiding the factory
  /// registration pitfall where separate instances would be created.
  void init(GetIt serviceLocator, {required AuthBloc authBloc}) {
    final authGuard = AuthRouteGuard(
      isAuthenticated: (context) {
        final authState = context.read<AuthBloc>().state;
        return authState is AuthAuthenticated;
      },
      redirectPath: AuthRoutes.login,
    );

    _refreshStream = GoRouterRefreshStream(authBloc.stream);

    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AuthRoutes.welcome,
      debugLogDiagnostics: true,
      refreshListenable: _refreshStream,
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final loc = state.matchedLocation;

        final isOnAuthFlow =
            loc == AuthRoutes.welcome ||
            loc == AuthRoutes.login ||
            loc.startsWith(AuthRoutes.login);

        // Authenticated users should not see auth screens.
        if (authState is AuthAuthenticated && isOnAuthFlow) {
          final from = state.uri.queryParameters['from'];
          if (from != null && from.isNotEmpty && from != loc) {
            return from;
          }
          return ArticleRoutes.feed;
        }

        // Explicit sign-out always returns to the welcome screen.
        if (authState is AuthSignedOut && loc != AuthRoutes.welcome) {
          final cameFromGuard = state.uri.queryParameters.containsKey('from');
          if (isOnAuthFlow && !cameFromGuard) {
            return null;
          }
          return AuthRoutes.welcome;
        }

        // Guest users (AuthUnauthenticated) may freely access feed, community,
        // and article detail. Per-route guards (authGuard) protect auth-only routes.
        return null;
      },
      routes: [
        // ── Auth screens (full-screen, outside the shell) ──────────────
        ...AuthRoutes.getRoutes(
          parentNavigatorKey: rootNavigatorKey,
          onGuestContinue: (context) => context.goToFeed(),
        ),

        // ── Bottom navigation shell ────────────────────────────────────
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainScaffold(navigationShell: navigationShell);
          },
          branches: [
            // Tab 0: Feed
            StatefulShellBranch(
              navigatorKey: _feedNavigatorKey,
              routes: [
                GoRoute(
                  path: ArticleRoutes.feed,
                  name: 'feed',
                  builder: (_, _) => BlocProvider(
                    create: (_) =>
                        serviceLocator<RemoteArticlesBloc>()
                          ..add(const GetArticles()),
                    child: const DailyNews(),
                  ),
                  routes: [
                    // Overlay routes (detail, search) rendered
                    // full-screen on root navigator via parentNavigatorKey.
                    ...ArticleRoutes.getOverlayRoutes(
                      serviceLocator: serviceLocator,
                      parentNavigatorKey: rootNavigatorKey,
                      authGuard: authGuard.check,
                    ),
                  ],
                ),
              ],
            ),
            // Tab 1: Community
            StatefulShellBranch(
              navigatorKey: _communityNavigatorKey,
              routes: CommunityRoutes.getCommunityBranchRoutes(
                serviceLocator: serviceLocator,
                parentNavigatorKey: rootNavigatorKey,
                subRoutes: ArticleRoutes.getDetailRoutes(
                  parentNavigatorKey: rootNavigatorKey,
                ),
              ),
            ),
            // Tab 2: Bookmarks / Saved
            StatefulShellBranch(
              navigatorKey: _bookmarksNavigatorKey,
              routes: BookmarkRoutes.getBranchRoutes(
                subRoutes: ArticleRoutes.getDetailRoutes(
                  parentNavigatorKey: rootNavigatorKey,
                ),
              ),
            ),
            // Tab 3: Write / Editor
            StatefulShellBranch(
              navigatorKey: _editorNavigatorKey,
              routes: CommunityRoutes.getEditorBranchRoutes(
                serviceLocator: serviceLocator,
                authGuard: authGuard.check,
              ),
            ),
          ],
        ),
      ],
      errorBuilder: _buildErrorPage,
    );
  }

  Widget _buildErrorPage(BuildContext context, GoRouterState state) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(ArticleRoutes.feed),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }

  /// Dispose resources.
  void dispose() {
    _refreshStream?.dispose();
  }
}
