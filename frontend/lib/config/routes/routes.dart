import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/screens/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/screens/home/daily_news.dart';
import '../../features/daily_news/presentation/screens/saved_article/saved_article.dart';
import '../../features/authentication/presentation/bloc/password_reset/password_reset_cubit.dart';
import '../../features/authentication/presentation/bloc/session/session_cubit.dart';
import '../../features/authentication/presentation/screens/account/account_screen.dart';
import '../../features/authentication/presentation/screens/password_reset/password_reset_screen.dart';
import '../../features/authentication/presentation/screens/sign_in/sign_in_screen.dart';
import '../../features/authentication/presentation/screens/sign_up/sign_up_screen.dart';
import '../../features/journalist_articles/domain/entities/journalist_article.dart';
import '../../features/journalist_articles/domain/use_cases/get_published_articles.dart';
import '../../features/journalist_articles/presentation/bloc/article_byline/article_byline_cubit.dart';
import '../../features/journalist_articles/presentation/bloc/article_editor/article_editor_cubit.dart';
import '../../features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import '../../features/journalist_articles/presentation/bloc/article_feed/article_feed_cubit.dart';
import '../../features/journalist_articles/presentation/bloc/article_reader/article_reader_cubit.dart';
import '../../features/journalist_articles/presentation/bloc/journalist_stats/journalist_stats_cubit.dart';
import '../../features/journalist_articles/presentation/bloc/my_articles/my_articles_cubit.dart';
import '../../features/journalist_articles/presentation/screens/article_editor/article_editor_screen.dart';
import '../../features/journalist_articles/presentation/screens/article_feed/article_feed_screen.dart';
import '../../features/journalist_articles/presentation/screens/article_published/article_published_screen.dart';
import '../../features/journalist_articles/presentation/screens/article_reader/article_reader_screen.dart';
import '../../features/journalist_articles/presentation/screens/my_articles/my_articles_screen.dart';
import '../../injection_container.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const DailyNews());

      case '/ArticleDetails':
        return _materialRoute(
          _newsReaderScreen(settings.arguments as ArticleEntity),
        );

      case '/SavedArticles':
        return _materialRoute(const SavedArticles());

      case '/MyArticles':
        return _materialRoute(_signedInOnly(_myArticlesScreen));

      case '/ArticleEditor':
        return _materialRoute(
          _signedInOnly(
            () => _articleEditorScreen(settings.arguments as String?),
          ),
        );

      case '/SignIn':
        return _materialRoute(const SignInScreen());

      case '/SignUp':
        return _materialRoute(const SignUpScreen());

      case '/PasswordReset':
        return _materialRoute(_passwordResetScreen());

      case '/Account':
        return _materialRoute(_signedInOnly(_accountScreen));

      case '/ArticleFeed':
        return _materialRoute(
          _articleFeedScreen(settings.arguments as Map<String, dynamic>?),
        );

      case '/ArticleReader':
        return _materialRoute(
          _articleReaderScreen(
            settings.arguments as JournalistArticleEntity,
          ),
        );

      case '/ArticlePublished':
        return _materialRoute(
          ArticlePublishedScreen(
            article: settings.arguments as JournalistArticleEntity,
          ),
        );

      default:
        return _materialRoute(const DailyNews());
    }
  }

  /// Writing needs an account; reading never does (decision #31).
  ///
  /// Guarding here instead of inside each screen keeps the policy in one
  /// place and keeps the screens unaware of sessions.
  static Widget _signedInOnly(Widget Function() screen) {
    return sl<SessionCubit>().state.isSignedIn
        ? screen()
        : const SignInScreen();
  }

  /// The cubits are provided here, at the composition root, so that the
  /// presentation layer never imports the injection container (and through it,
  /// the data layer).
  ///
  /// The journalist's identity comes from the session, which
  /// [_signedInOnly] has already checked by the time these run.
  static Widget _myArticlesScreen() {
    final journalist = sl<SessionCubit>().state.user!;

    return BlocProvider<MyArticlesCubit>(
      create: (_) => MyArticlesCubit(
        sl(),
        sl(),
        sl(),
        journalistId: journalist.id,
      )..loadArticles(),
      child: const MyArticlesScreen(),
    );
  }

  /// The account screen reaches into two of the journalist's cubits: the
  /// summary of their work, and the byline their published articles carry.
  /// Both are singletons, so `.value` — a provider that created them would
  /// close them when this route is popped.
  static Widget _accountScreen() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<JournalistStatsCubit>.value(
          value: sl<JournalistStatsCubit>(),
        ),
        BlocProvider<ArticleBylineCubit>.value(
          value: sl<ArticleBylineCubit>(),
        ),
      ],
      child: const AccountScreen(),
    );
  }

  /// [articleId] is null when the journalist is writing a new article.
  static Widget _articleEditorScreen(String? articleId) {
    final journalist = sl<SessionCubit>().state.user!;

    return BlocProvider<ArticleEditorCubit>(
      create: (_) {
        final cubit = ArticleEditorCubit(
          sl(),
          sl(),
          sl(),
          sl(),
          sl(),
          sl(),
          journalistId: journalist.id,
          journalistName: journalist.authorName,
        );

        if (articleId == null) {
          cubit.startNewArticle();
        } else {
          cubit.loadArticle(articleId);
        }

        return cubit;
      },
      child: const ArticleEditorScreen(),
    );
  }

  /// The community reader needs two cubits: one that counts the reading, and
  /// one that finds the rest of the author's work for the strip underneath.
  static Widget _articleReaderScreen(JournalistArticleEntity article) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ArticleReaderCubit>(
          create: (_) =>
              ArticleReaderCubit(sl(), article: article)..recordView(),
        ),
        BlocProvider<ArticleFeedCubit>(
          create: (_) => ArticleFeedCubit(
            sl<GetPublishedArticlesUseCase>(),
            authorId: article.userId,
            excludeArticleId: article.id,
            // An author's back catalogue, not this week's news.
            onlyRecent: false,
            pageSize: 6,
          )..loadFeed(),
        ),
      ],
      child: const ArticleReaderScreen(),
    );
  }

  /// The news reader shares the app's one saved-articles bloc, so that saving
  /// here shows up in the Saved tab, and so this screen can tell whether the
  /// article is already saved.
  ///
  /// `.value` rather than `create`: the bloc is a singleton, and a provider
  /// that created it would close it when this screen is popped.
  static Widget _newsReaderScreen(ArticleEntity article) {
    return BlocProvider<LocalArticleBloc>.value(
      value: sl<LocalArticleBloc>(),
      child: ArticleDetailsView(article: article),
    );
  }

  static Widget _passwordResetScreen() {
    return BlocProvider<PasswordResetCubit>(
      create: (_) => sl<PasswordResetCubit>(),
      child: const PasswordResetScreen(),
    );
  }

  /// [args] carries `authorId`/`excludeArticleId`/`title` when this is "more
  /// from this author" (see `ArticleReaderScreen`); left null it is the
  /// general community feed. A plain map is used instead of a typed class so
  /// this stays a routing-only concern, the same way `_articleEditorScreen`
  /// takes a raw `String?` instead of a dedicated argument type.
  static Widget _articleFeedScreen(Map<String, dynamic>? args) {
    final authorId = args?['authorId'] as String?;

    return BlocProvider<ArticleFeedCubit>(
      create: (_) => ArticleFeedCubit(
        sl<GetPublishedArticlesUseCase>(),
        authorId: authorId,
        excludeArticleId: args?['excludeArticleId'] as String?,
        // An author's page lists their whole catalogue; only the community
        // feed is limited to the last week.
        onlyRecent: authorId == null,
      )..loadFeed(),
      child: ArticleFeedScreen(titleOverride: args?['title'] as String?),
    );
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
