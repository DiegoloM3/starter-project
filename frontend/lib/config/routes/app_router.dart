import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/scaffold_with_nav_bar.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/my_articles/my_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_event.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/screens/article_edit/article_edit_page.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/screens/article_upload/article_upload_page.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/screens/my_articles/my_articles_page.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/login/login_page.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/signup/signup_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/saved_article/saved_article.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/screens/settings_page.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

/// Creates and configures the app-wide [GoRouter].
///
/// Top-level shell (bottom navigation bar):
///   /               → DailyNews
///   /settings       → SettingsPage
///
/// Full-screen routes (no bottom nav):
///   /article/upload → ArticleUploadPage (auth-required)
///   /article/edit/:id → ArticleEditPage (auth-required)
///   /my-articles    → MyArticlesPage (auth-required)
///   /article/:id    → ArticleDetails
///   /saved          → SavedArticles (auth-required)
///   /login          → LoginPage
///   /signup         → SignupPage
class AppRouter {
  const AppRouter._();

  /// Factory method that wires [AuthBloc] to [GoRouterRefreshStream].
  static GoRouter create(AuthBloc authBloc) {
    String? requireAuth(GoRouterState state) {
      if (authBloc.state is AuthAuthenticated) return null;
      final returnTo = Uri.encodeComponent(state.uri.toString());
      return '/login?return=$returnTo';
    }

    return GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final loc = state.matchedLocation;
        // Once authenticated, /login and /signup are no-ops — bounce home.
        if (authState is AuthAuthenticated &&
            (loc == '/login' || loc == '/signup')) {
          return '/';
        }
        return null;
      },
      routes: [
        // Top-level shell with bottom navigation. Each branch keeps its
        // own Navigator stack so switching tabs preserves scroll/state.
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              ScaffoldWithNavBar(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const DailyNews(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  builder: (context, state) => const SettingsPage(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/article/upload',
          redirect: (context, state) => requireAuth(state),
          builder: (context, state) {
            final draftIdRaw = state.uri.queryParameters['draftId'];
            final draftId = draftIdRaw == null ? null : int.tryParse(draftIdRaw);
            return BlocProvider<UploadArticleBloc>(
              create: (_) {
                final bloc = sl<UploadArticleBloc>();
                if (draftId != null) {
                  bloc.add(LoadDraftEvent(draftId));
                }
                return bloc;
              },
              child: const ArticleUploadPage(),
            );
          },
        ),
        GoRoute(
          path: '/article/edit/:id',
          redirect: (context, state) => requireAuth(state),
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BlocProvider<UploadArticleBloc>(
              create: (_) => sl<UploadArticleBloc>(),
              child: ArticleEditPage(articleId: id),
            );
          },
        ),
        GoRoute(
          path: '/my-articles',
          redirect: (context, state) => requireAuth(state),
          builder: (context, state) {
            final uid =
                (authBloc.state as AuthAuthenticated).user.uid;
            return BlocProvider<MyArticlesBloc>(
              create: (_) => sl<MyArticlesBloc>(),
              child: MyArticlesPage(userId: uid),
            );
          },
        ),
        GoRoute(
          path: '/article/:id',
          builder: (context, state) {
            final article = state.extra as ArticleEntity?;
            if (article != null) {
              return ArticleDetailsView(article: article);
            }
            final id = state.pathParameters['id']!;
            return ArticleDetailsView(communityArticleId: id);
          },
        ),
        GoRoute(
          path: '/saved',
          redirect: (context, state) => requireAuth(state),
          builder: (context, state) => const SavedArticles(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupPage(),
        ),
      ],
    );
  }
}

/// Bridges a [Stream] to the [ChangeNotifier] interface expected by
/// [GoRouter.refreshListenable].
///
/// Subscribes to [stream] in the constructor, calls [notifyListeners]
/// on each emission, and cancels the subscription in [dispose].
class GoRouterRefreshStream extends ChangeNotifier {
  StreamSubscription<dynamic>? _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
