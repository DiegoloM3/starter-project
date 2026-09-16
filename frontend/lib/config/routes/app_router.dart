import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/config/routes/session_redirect.dart';
import 'package:news_app_clean_architecture/config/routes/stream_refresh_listenable.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/edit_profile_screen.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/splash_screen.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/welcome_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/brief_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home_shell_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/my_articles_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/publish_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/reader_screen.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/screens/default_category_screen.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/screens/settings_screen.dart';

/// Builds the app's router. Redirects follow [SessionRedirect] and re-run
/// every time the session changes.
abstract final class AppRouter {
  static GoRouter build(SessionCubit sessionCubit) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: StreamRefreshListenable(sessionCubit.stream),
      redirect: (context, state) => SessionRedirect.resolve(
        session: sessionCubit.state,
        location: state.matchedLocation,
      ),
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.signIn,
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: AppRoutes.signUp,
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => HomeShellScreen(
            initialTab: int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0,
          ),
        ),
        GoRoute(
          path: AppRoutes.reader,
          redirect: (context, state) => state.extra is ArticleEntity ? null : AppRoutes.home,
          builder: (context, state) => ReaderScreen(article: state.extra! as ArticleEntity),
        ),
        GoRoute(
          path: AppRoutes.brief,
          pageBuilder: (context, state) => const MaterialPage(fullscreenDialog: true, child: BriefScreen()),
        ),
        GoRoute(
          path: AppRoutes.publish,
          builder: (context, state) => PublishScreen(article: state.extra as ArticleEntity?),
        ),
        GoRoute(
          path: AppRoutes.myArticles,
          builder: (context, state) => const MyArticlesScreen(),
        ),
        GoRoute(
          path: AppRoutes.editProfile,
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'category',
              builder: (context, state) => const DefaultCategoryScreen(),
            ),
          ],
        ),
      ],
    );
  }
}

/// Navigation helpers so screens never spell out paths.
extension AppNavigation on BuildContext {
  void goToSignIn() => go(AppRoutes.signIn);

  void goToSignUp() => go(AppRoutes.signUp);

  void goToWelcome() => go(AppRoutes.welcome);

  /// [tab]: 0 Home, 1 Search, 2 Saved, 3 Profile.
  void goHome({int tab = 0}) => go(tab == 0 ? AppRoutes.home : '${AppRoutes.home}?tab=$tab');

  void pushSettings() => push(AppRoutes.settings);

  void pushEditProfile() => push(AppRoutes.editProfile);

  void pushReader(ArticleEntity article) => push(AppRoutes.reader, extra: article);

  void pushPublish({ArticleEntity? article}) => push(AppRoutes.publish, extra: article);

  void pushMyArticles() => push(AppRoutes.myArticles);

  void pushBrief() => push(AppRoutes.brief);

  void pushDefaultCategoryPicker() => push(AppRoutes.settingsCategory);
}
