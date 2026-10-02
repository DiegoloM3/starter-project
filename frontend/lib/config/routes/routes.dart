import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/register/register_cubit.dart';
import '../../features/auth/presentation/bloc/sign_in/sign_in_cubit.dart';
import '../../features/auth/presentation/screens/register/register_screen.dart';
import '../../features/auth/presentation/screens/sign_in/sign_in_screen.dart';
import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/bloc/article/bookmark/article_bookmark_cubit.dart';
import '../../features/daily_news/presentation/screens/article_detail/article_detail_screen.dart';
import '../../features/journalist_articles/domain/entities/journalist_article.dart';
import '../../features/journalist_articles/presentation/bloc/add_article_comment/add_article_comment_cubit.dart';
import '../../features/journalist_articles/presentation/bloc/article_comments/article_comments_cubit.dart';
import '../../features/journalist_articles/presentation/bloc/journalist_article_bookmark/journalist_article_bookmark_cubit.dart';
import '../../features/journalist_articles/presentation/bloc/publish_article/publish_article_cubit.dart';
import '../../features/journalist_articles/presentation/screens/journalist_article_detail/journalist_article_detail_screen.dart';
import '../../features/journalist_articles/presentation/screens/publish_article/publish_article_screen.dart';
import '../../injection_container.dart';
import 'package:news_app_clean_architecture/core/constants/route_names.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.signIn:
        return _materialRoute(BlocProvider(
          create: (_) => sl<SignInCubit>(),
          child: const SignInScreen(),
        ));

      case RouteNames.register:
        return _materialRoute(BlocProvider(
          create: (_) => sl<RegisterCubit>(),
          child: const RegisterScreen(),
        ));

      case RouteNames.articleDetails:
        return _materialRoute(_buildArticleDetails(settings.arguments as ArticleEntity));

      case RouteNames.publishArticle:
        return _materialRoute(BlocProvider(
          create: (_) => sl<PublishArticleCubit>(),
          child: const PublishArticleScreen(),
        ));

      case RouteNames.journalistArticleDetails:
        return _materialRoute(_buildJournalistArticleDetails(settings.arguments as JournalistArticleEntity));

      // Every screen is opened by one of the names above; any other name is a programming error.
      default:
        throw ArgumentError.value(settings.name, 'settings.name', 'There is no route with this name');
    }
  }

  static Widget _buildArticleDetails(ArticleEntity article) {
    return BlocProvider(
      create: (_) => sl<ArticleBookmarkCubit>(param1: article)..loadBookmark(),
      child: ArticleDetailScreen(article: article),
    );
  }

  static Widget _buildJournalistArticleDetails(JournalistArticleEntity article) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ArticleCommentsCubit>(param1: article.id)..loadComments()),
        BlocProvider(create: (_) => sl<AddArticleCommentCubit>(param1: article.id)),
        BlocProvider(create: (_) => sl<JournalistArticleBookmarkCubit>(param1: article.id)..loadBookmark()),
      ],
      child: JournalistArticleDetailScreen(article: article),
    );
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
