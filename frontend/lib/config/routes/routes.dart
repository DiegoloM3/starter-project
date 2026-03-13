import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';

// Auth Feature
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/settings_page.dart';
import '../../features/auth/presentation/pages/edit_profile_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';

// User Articles Feature
import '../../features/user_articles/domain/entities/user_article.dart';
import '../../features/user_articles/presentation/pages/home_page.dart';
import '../../features/user_articles/presentation/pages/my_articles_page.dart';
import '../../features/user_articles/presentation/pages/user_article_detail_page.dart';
import '../../features/user_articles/presentation/pages/article_editor_page.dart';
import '../../features/user_articles/presentation/bloc/article_editor/article_editor_cubit.dart';
import '../../features/user_articles/presentation/bloc/article_detail/tts_cubit.dart';
import '../../injection_container.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      // Auth routes
      case '/':
      case '/Login':
        return _materialRoute(const _AuthWrapper());

      case '/Profile':
        return _materialRoute(const ProfilePage());

      case '/Settings':
        return _materialRoute(const SettingsPage());

      case '/EditProfile':
        return _materialRoute(const EditProfilePage());

      case '/ForgotPassword':
        return _materialRoute(const ForgotPasswordPage());

      // User Articles routes
      case '/Home':
        return _materialRoute(const HomePage());

      case '/MyArticles':
        return _materialRoute(const MyArticlesPage());

      case '/UserArticleDetail':
        return _materialRoute(
          BlocProvider<TtsCubit>(
            create: (context) => sl<TtsCubit>(),
            child: UserArticleDetailPage(
              article: settings.arguments as UserArticleEntity,
            ),
          ),
        );

      case '/ArticleEditor':
        return _materialRoute(
          BlocProvider<ArticleEditorCubit>(
            create: (context) => sl<ArticleEditorCubit>(),
            child: ArticleEditorPage(
              article: settings.arguments as UserArticleEntity?,
            ),
          ),
        );

      // Daily News routes (legacy)
      case '/DailyNews':
        return _materialRoute(const DailyNews());

      case '/ArticleDetails':
        return _materialRoute(
          ArticleDetailsView(article: settings.arguments as ArticleEntity),
        );

      case '/SavedArticles':
        return _materialRoute(const SavedArticles());

      default:
        return _materialRoute(const _AuthWrapper());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}

/// Wrapper widget that redirects based on auth state
class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is Authenticated) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
