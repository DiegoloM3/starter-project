import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/core/session/auth_session.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/auth_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/saved_article/saved_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/pages/article_editor/article_editor_page.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/pages/my_articles/my_articles_page.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/pages/user_article_detail/user_article_detail_page.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

/// Top-level [GoRouter] used by `MaterialApp.router`.
///
/// Wires the auth-aware redirect: anything under `AppRoutes.protectedPathPrefixes`
/// requires a signed-in user; otherwise the request is bounced to `/auth?next=…`.
/// `refreshListenable` re-evaluates the redirect when the auth state changes.
final appRouter = GoRouter(
  initialLocation: AppRoutes.home(),
  refreshListenable: _AuthChangesNotifier(sl<AuthSession>().changes),
  redirect: _redirect,
  routes: [
    GoRoute(
      path: AppRoutes.home(),
      name: AppRoutes.homeName,
      builder: (context, state) => const DailyNews(),
    ),
    GoRoute(
      path: AppRoutes.saved(),
      name: AppRoutes.savedName,
      builder: (context, state) => const SavedArticles(),
    ),
    GoRoute(
      path: AppRoutes.auth(),
      name: AppRoutes.authName,
      builder: (context, state) {
        return AuthPage(next: state.uri.queryParameters['next']);
      },
    ),
    GoRoute(
      path: '/article/:id',
      name: AppRoutes.articleDetailName,
      builder: (context, state) {
        final article = state.extra as ArticleEntity?;
        return ArticleDetailsView(article: article);
      },
    ),
    GoRoute(
      path: AppRoutes.myArticles(),
      name: AppRoutes.myArticlesName,
      builder: (context, state) => const MyArticlesPage(),
      routes: [
        GoRoute(
          path: 'new',
          name: AppRoutes.articleEditorNewName,
          builder: (context, state) => const ArticleEditorPage(),
        ),
        GoRoute(
          path: ':id',
          name: AppRoutes.userArticleDetailName,
          builder: (context, state) {
            final article = state.extra as UserArticleEntity?;
            if (article == null) {
              return const _MissingArticlePage();
            }
            return UserArticleDetailPage(article: article);
          },
          routes: [
            GoRoute(
              path: 'edit',
              name: AppRoutes.articleEditorEditName,
              builder: (context, state) {
                final article = state.extra as UserArticleEntity?;
                return ArticleEditorPage(editing: article);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);

String? _redirect(BuildContext context, GoRouterState state) {
  final session = sl<AuthSession>();
  final isLoggedIn = session.currentUser != null;
  final location = state.matchedLocation;
  final isAuthRoute = location == AppRoutes.auth();
  final isProtected =
      AppRoutes.protectedPathPrefixes.any(location.startsWith);

  if (!isLoggedIn && isProtected) {
    final next = Uri.encodeComponent(state.uri.toString());
    return '${AppRoutes.auth()}?next=$next';
  }

  if (isLoggedIn && isAuthRoute) {
    final next = state.uri.queryParameters['next'];
    if (next != null && next.isNotEmpty) return next;
    return AppRoutes.home();
  }

  return null;
}

/// Bridges a `Stream<AuthUser?>` into a [Listenable] that go_router can use
/// as `refreshListenable`. Each emission triggers a redirect re-evaluation.
class _AuthChangesNotifier extends ChangeNotifier {
  _AuthChangesNotifier(Stream<AuthUser?> stream) {
    // ignore: unnecessary_lambdas — listen needs a `Function(T)` and
    // `notifyListeners` takes no argument, so a tearoff isn't possible.
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthUser?> _sub;

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}

class _MissingArticlePage extends StatelessWidget {
  const _MissingArticlePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Article not found')),
    );
  }
}
