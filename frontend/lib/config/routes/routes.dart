import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/comments/presentation/bloc/comments_cubit.dart';
import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import '../../features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import '../../features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import '../../features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';
import '../../features/upload_article/domain/entities/user_article.dart';
import '../../features/upload_article/presentation/bloc/my_articles_cubit.dart';
import '../../features/upload_article/presentation/bloc/my_articles_state.dart';
import '../../features/upload_article/presentation/bloc/upload_article_cubit.dart';
import '../../features/upload_article/presentation/screens/my_articles_screen.dart';
import '../../features/upload_article/presentation/screens/upload_article_screen.dart';
import '../../features/upload_article/presentation/screens/user_article_detail_screen.dart';
import '../../injection_container.dart';
import '../../shared/auth/presentation/screens/profile_screen.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(buildDailyNews());

      case '/ArticleDetails':
        final article = settings.arguments as ArticleEntity;
        final view = ArticleDetailsView(article: article);
        return _materialRoute(kIsWeb
            ? view
            : BlocProvider<LocalArticleBloc>(
                create: (_) => sl<LocalArticleBloc>(),
                child: view,
              ));

      case '/SavedArticles':
        return _materialRoute(BlocProvider<LocalArticleBloc>(
          create: (_) =>
              sl<LocalArticleBloc>()..add(const GetSavedArticles()),
          child: const SavedArticles(),
        ));

      case '/UploadArticle':
        return _materialRoute(BlocProvider<UploadArticleCubit>(
          create: (_) => sl<UploadArticleCubit>(),
          child: UploadArticleScreen(
            existing: settings.arguments as UserArticleEntity?,
          ),
        ));

      case '/MyArticles':
        return _materialRoute(BlocProvider<MyArticlesCubit>(
          create: (_) =>
              sl<MyArticlesCubit>()..load(ArticlesFilter.mine),
          child: const MyArticlesScreen(),
        ));

      case '/UserArticleDetails':
        final article = settings.arguments as UserArticleEntity;
        final screen = UserArticleDetailScreen(article: article);
        final articleId = article.id;
        if (articleId == null) return _materialRoute(screen);
        return _materialRoute(BlocProvider<CommentsCubit>(
          create: (_) => sl<CommentsCubit>()..load(articleId),
          child: screen,
        ));

      case '/Profile':
        return _materialRoute(const ProfileScreen());

      default:
        return _materialRoute(buildDailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}

Widget buildDailyNews() {
  return MultiBlocProvider(
    providers: [
      BlocProvider<RemoteArticlesBloc>(
        create: (_) => sl<RemoteArticlesBloc>()..add(const GetArticles()),
      ),
      BlocProvider<MyArticlesCubit>(
        create: (_) => sl<MyArticlesCubit>()..load(ArticlesFilter.all),
      ),
    ],
    child: const DailyNews(),
  );
}
