import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/app_routes.dart';
import '../domain/entities/article_entity.dart';
import '../presentation/bloc/create_article/create_article_cubit.dart';
import '../presentation/screens/article_detail_screen.dart';
import '../presentation/screens/create_article_screen.dart';
import '../presentation/screens/feed_screen.dart';

class ArticlesRoutes {
  ArticlesRoutes._();

  // Fuera del shell — sin TabBar
  static final routes = <RouteBase>[
    GoRoute(
      path: '/article/:articleId',
      builder: (_, state) => ArticleDetailScreen(
        articleId: state.pathParameters['articleId']!,
      ),
    ),
    GoRoute(
      path: AppRoutes.editArticle,
      builder: (_, state) => BlocProvider(
        create: (_) => GetIt.instance<CreateArticleCubit>(),
        child: CreateArticleScreen(
          article: state.extra as ArticleEntity,
        ),
      ),
    ),
  ];

  // Dentro del shell — con TabBar
  static final shellRoutes = <RouteBase>[
    GoRoute(
      path: AppRoutes.feed,
      pageBuilder: (_, _) => const NoTransitionPage(child: FeedScreen()),
    ),
  ];
}
