import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article_entity.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/create_community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/delete_community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/get_community_article_by_id.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/get_community_articles.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/pick_cover_image.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/update_community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/watch_community_articles.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/detail/community_article_detail_bloc.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/detail/community_article_detail_event.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/editor/community_article_editor_bloc.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/articles/community_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/articles/community_articles_event.dart';

import '../presentation/pages/community_article_detail_screen.dart';
import '../presentation/pages/create_article_screen.dart';
import '../presentation/pages/home_community_tab.dart';

/// Path constants and route configuration for the community articles feature.
abstract final class CommunityRoutes {
  CommunityRoutes._();

  // ══════════════════════════════════════════════════════════════════
  // Path Constants
  // ══════════════════════════════════════════════════════════════════

  static const String community = '/community';
  static const String editor = '/editor';

  // ══════════════════════════════════════════════════════════════════
  // Route Configuration
  // ══════════════════════════════════════════════════════════════════

  /// Routes for the community shell branch.
  ///
  /// Includes the community list and a tab-aware article detail sub-route
  /// so that back navigation returns to the community tab.
  static List<RouteBase> getCommunityBranchRoutes({
    required GetIt serviceLocator,
    GlobalKey<NavigatorState>? parentNavigatorKey,
    List<RouteBase> subRoutes = const [],
  }) {
    return [
      GoRoute(
        path: community,
        name: 'community',
        builder: (_, _) => BlocProvider(
          create: (_) => CommunityArticlesBloc(
            serviceLocator<GetCommunityArticlesUseCase>(),
            serviceLocator<WatchCommunityArticlesUseCase>(),
          )..add(const CommunityArticlesRequested()),
          child: const HomeCommunityTab(),
        ),
        routes: [
          ...subRoutes,
          GoRoute(
            path: 'detail',
            parentNavigatorKey: parentNavigatorKey,
            builder: (_, state) {
              final extra = state.extra;
              final article = extra is CommunityArticleEntity ? extra : null;
              final articleId = extra is String ? extra : null;
              final title = article?.title;
              return BlocProvider(
                create: (_) =>
                    CommunityArticleDetailBloc(
                      serviceLocator<GetCommunityArticleByIdUseCase>(),
                      serviceLocator<DeleteCommunityArticleUseCase>(),
                    )..add(
                      CommunityArticleDetailStarted(
                        article: article,
                        articleId: articleId,
                      ),
                    ),
                child: CommunityArticleDetailScreen(title: title),
              );
            },
          ),
        ],
      ),
    ];
  }

  /// Routes for the editor shell branch.
  static List<RouteBase> getEditorBranchRoutes({
    required GetIt serviceLocator,
    String? Function(BuildContext, GoRouterState)? authGuard,
  }) {
    return [
      GoRoute(
        path: editor,
        name: 'editor',
        redirect: authGuard,
        builder: (_, state) {
          final extra = state.extra;
          final article = extra is CommunityArticleEntity ? extra : null;
          return BlocProvider(
            create: (_) => CommunityArticleEditorBloc(
              serviceLocator<CreateCommunityArticleUseCase>(),
              serviceLocator<UpdateCommunityArticleUseCase>(),
              serviceLocator<PickCoverImageUseCase>(),
            ),
            child: CreateArticleScreen(article: article),
          );
        },
      ),
    ];
  }
}

// ══════════════════════════════════════════════════════════════════
// Navigation Extensions
// ══════════════════════════════════════════════════════════════════

/// Extension for type-safe navigation to community screens.
extension CommunityNavigation on BuildContext {
  /// Navigate to community page.
  void goToCommunity() => go(CommunityRoutes.community);

  /// Navigate to a community article detail page.
  void goToCommunityDetail(CommunityArticleEntity article) =>
      go('${CommunityRoutes.community}/detail', extra: article);

  /// Navigate to a community article detail page by id.
  void goToCommunityDetailById(String id) =>
      go('${CommunityRoutes.community}/detail', extra: id);

  /// Navigate to article editor (create / edit).
  void goToEditor({CommunityArticleEntity? article}) =>
      go(CommunityRoutes.editor, extra: article);
}
