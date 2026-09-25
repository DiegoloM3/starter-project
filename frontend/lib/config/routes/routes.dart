import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/bloc/search/search_cubit.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/search/search_screen.dart';
import '../../features/user_articles/domain/entities/user_article_entity.dart';
import '../../features/user_articles/presentation/bloc/detail/user_article_detail_cubit.dart';
import '../../features/user_articles/presentation/bloc/form/user_article_form_cubit.dart';
import '../../features/user_articles/presentation/screens/user_article_detail_screen.dart';
import '../../features/user_articles/presentation/screens/user_article_form_screen.dart';
import '../../injection_container.dart';
import '../navigation/main_shell.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const MainShell());

      case '/ArticleDetails':
        return _materialRoute(ArticleDetailsView(article: settings.arguments as ArticleEntity));

      case '/Search':
        return _materialRoute(
          BlocProvider<SearchCubit>(
            create: (_) => sl<SearchCubit>()..showHistory(),
            child: const SearchScreen(),
          ),
        );

      case '/UserArticleDetail':
        return _materialRoute(
          BlocProvider<UserArticleDetailCubit>(
            create: (_) => sl(),
            child: UserArticleDetailScreen(articleId: settings.arguments as String),
          ),
        );

      case '/UserArticleForm':
        return _materialRoute(
          BlocProvider<UserArticleFormCubit>(
            create: (_) => sl(),
            child: UserArticleFormScreen(
              existingArticle: settings.arguments as UserArticleEntity?,
            ),
          ),
        );

      default:
        return _materialRoute(const MainShell());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
