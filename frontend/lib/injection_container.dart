import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import 'config/firebase_options.dart';
import 'features/auth/data/data_sources/firebase_auth_data_source.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/community_articles/data/data_sources/article_image_picker_data_source.dart';
import 'features/community_articles/data/data_sources/community_firestore_data_source.dart';
import 'features/community_articles/data/repository/community_article_repository_impl.dart';
import 'features/community_articles/data/data_sources/community_social_firestore_data_source.dart';
import 'features/community_articles/data/repository/community_social_repository_impl.dart';
import 'features/community_articles/domain/repository/community_article_repository.dart';
import 'features/community_articles/domain/repository/community_article_lookup_repository.dart';
import 'features/community_articles/domain/repository/community_social_repository.dart';
import 'features/community_articles/domain/usecases/get_community_articles.dart';
import 'features/community_articles/domain/usecases/get_community_article.dart';
import 'features/community_articles/domain/usecases/social_interactions.dart';
import 'features/community_articles/domain/usecases/pick_article_image.dart';
import 'features/community_articles/domain/usecases/publish_article.dart';
import 'features/community_articles/presentation/bloc/community_feed_cubit.dart';
import 'features/community_articles/presentation/bloc/community_article_lookup_cubit.dart';
import 'features/community_articles/presentation/bloc/social_interactions_cubit.dart';
import 'features/community_articles/presentation/services/article_share_service.dart';
import 'features/community_articles/presentation/bloc/publish_article_cubit.dart';
import 'features/daily_news/data/data_sources/local/article_local_data_source.dart';
import 'features/daily_news/data/data_sources/local/legacy_article_local_data_source.dart';
import 'features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'features/daily_news/data/data_sources/remote/news_api_data_source.dart';
import 'features/daily_news/data/repository/article_repository_impl.dart';
import 'features/daily_news/domain/repository/article_repository.dart';
import 'features/daily_news/domain/usecases/get_article.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';

final sl = GetIt.instance;

class _DependencyInitializationMarker {
  const _DependencyInitializationMarker();
}

class _DependencyRegistrationTransaction {
  final GetIt container;
  final List<FutureOr<void> Function()> _rollbackActions = [];

  _DependencyRegistrationTransaction(this.container);

  void registerSingleton<T extends Object>(T instance) {
    container.registerSingleton<T>(instance);
    _rollbackActions.add(() => container.unregister<T>());
  }

  void registerFactory<T extends Object>(FactoryFunc<T> factory) {
    container.registerFactory<T>(factory);
    _rollbackActions.add(() => container.unregister<T>());
  }

  void registerFactoryParam<T extends Object, P1, P2>(
    FactoryFuncParam<T, P1, P2> factory,
  ) {
    container.registerFactoryParam<T, P1, P2>(factory);
    _rollbackActions.add(() => container.unregister<T>());
  }

  void commit() => _rollbackActions.clear();

  Future<void> rollback() async {
    for (final action in _rollbackActions.reversed) {
      await action();
    }
    _rollbackActions.clear();
  }
}

void _registerSingletonIfAbsent<T extends Object>(
  GetIt container,
  _DependencyRegistrationTransaction transaction,
  T Function() factory,
) {
  if (container.isRegistered<T>()) return;
  transaction.registerSingleton<T>(factory());
}

void _registerFactoryIfAbsent<T extends Object>(
  GetIt container,
  _DependencyRegistrationTransaction transaction,
  FactoryFunc<T> factory,
) {
  if (container.isRegistered<T>()) return;
  transaction.registerFactory<T>(factory);
}

void _registerFactoryParamIfAbsent<T extends Object, P1, P2>(
  GetIt container,
  _DependencyRegistrationTransaction transaction,
  FactoryFuncParam<T, P1, P2> factory,
) {
  if (container.isRegistered<T>()) return;
  transaction.registerFactoryParam<T, P1, P2>(factory);
}

void registerLocalArticleDataSource(
  ArticleLocalDataSource localArticles, {
  GetIt? container,
}) {
  final target = container ?? sl;
  if (!target.isRegistered<ArticleLocalDataSource>()) {
    target.registerSingleton<ArticleLocalDataSource>(localArticles);
  }
}

Future<void> initializeDependencies({
  GetIt? container,
  Future<ArticleLocalDataSource> Function()? localDataSourceFactory,
}) async {
  final graph = container ?? sl;
  if (graph.isRegistered<_DependencyInitializationMarker>()) return;

  final transaction = _DependencyRegistrationTransaction(graph);
  try {
    final localArticles = graph.isRegistered<ArticleLocalDataSource>()
        ? graph<ArticleLocalDataSource>()
        : await (localDataSourceFactory ??
            createLegacyArticleLocalDataSource)();
    _registerSingletonIfAbsent<ArticleLocalDataSource>(
      graph,
      transaction,
      () => localArticles,
    );
    _registerSingletonIfAbsent<Dio>(graph, transaction, Dio.new);
    _registerSingletonIfAbsent<NewsApiService>(
      graph,
      transaction,
      () => NewsApiService(graph<Dio>()),
    );
    _registerSingletonIfAbsent<NewsArticlesDataSource>(
      graph,
      transaction,
      () => NewsApiDataSource(graph<NewsApiService>()),
    );
    _registerSingletonIfAbsent<ArticleRepository>(
      graph,
      transaction,
      () => ArticleRepositoryImpl(
        graph<NewsArticlesDataSource>(),
        graph<ArticleLocalDataSource>(),
      ),
    );

    _registerSingletonIfAbsent<GetArticleUseCase>(
      graph,
      transaction,
      () => GetArticleUseCase(graph<ArticleRepository>()),
    );
    _registerSingletonIfAbsent<GetSavedArticleUseCase>(
      graph,
      transaction,
      () => GetSavedArticleUseCase(graph<ArticleRepository>()),
    );
    _registerSingletonIfAbsent<SaveArticleUseCase>(
      graph,
      transaction,
      () => SaveArticleUseCase(graph<ArticleRepository>()),
    );
    _registerSingletonIfAbsent<RemoveArticleUseCase>(
      graph,
      transaction,
      () => RemoveArticleUseCase(graph<ArticleRepository>()),
    );

    _registerFactoryIfAbsent<RemoteArticlesBloc>(
      graph,
      transaction,
      () => RemoteArticlesBloc(graph<GetArticleUseCase>()),
    );
    _registerFactoryIfAbsent<LocalArticleBloc>(
      graph,
      transaction,
      () => LocalArticleBloc(
        graph<GetSavedArticleUseCase>(),
        graph<SaveArticleUseCase>(),
        graph<RemoveArticleUseCase>(),
      ),
    );

    if (!graph.isRegistered<AuthRepository>()) {
      final authDataSource = FirebaseAuthDataSource(FirebaseAuth.instance);
      _registerSingletonIfAbsent<AuthRepository>(
        graph,
        transaction,
        () => AuthRepositoryImpl(authDataSource),
      );
    }
    _registerSingletonIfAbsent<SignInUseCase>(
      graph,
      transaction,
      () => SignInUseCase(graph<AuthRepository>()),
    );
    _registerSingletonIfAbsent<SignUpUseCase>(
      graph,
      transaction,
      () => SignUpUseCase(graph<AuthRepository>()),
    );
    _registerSingletonIfAbsent<SignOutUseCase>(
      graph,
      transaction,
      () => SignOutUseCase(graph<AuthRepository>()),
    );
    _registerSingletonIfAbsent<AuthCubit>(
      graph,
      transaction,
      () => AuthCubit(
        graph<AuthRepository>(),
        graph<SignInUseCase>(),
        graph<SignUpUseCase>(),
        graph<SignOutUseCase>(),
      ),
    );

    if (!graph.isRegistered<CommunityArticleRepository>()) {
      final firestoreDataSource = CommunityFirestoreDataSource(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: firebaseFirestoreDatabaseId,
        ),
        storage: FirebaseStorage.instance,
      );
      final communityArticleRepository = CommunityArticleRepositoryImpl(
        firestoreDataSource,
        ArticleImagePickerDataSource(),
      );
      _registerSingletonIfAbsent<CommunityArticleRepository>(
        graph,
        transaction,
        () => communityArticleRepository,
      );
    }
    _registerSingletonIfAbsent<CommunityArticleLookupRepository>(
      graph,
      transaction,
      () => graph<CommunityArticleRepository>()
          as CommunityArticleLookupRepository,
    );
    _registerSingletonIfAbsent<GetCommunityArticlesUseCase>(
      graph,
      transaction,
      () => GetCommunityArticlesUseCase(
        graph<CommunityArticleRepository>(),
      ),
    );
    _registerSingletonIfAbsent<GetCommunityArticleUseCase>(
      graph,
      transaction,
      () => GetCommunityArticleUseCase(
        graph<CommunityArticleLookupRepository>(),
      ),
    );
    _registerSingletonIfAbsent<PublishArticleUseCase>(
      graph,
      transaction,
      () => PublishArticleUseCase(graph<CommunityArticleRepository>()),
    );
    _registerSingletonIfAbsent<PickArticleImageUseCase>(
      graph,
      transaction,
      () => PickArticleImageUseCase(graph<CommunityArticleRepository>()),
    );
    _registerFactoryIfAbsent<CommunityFeedCubit>(
      graph,
      transaction,
      () => CommunityFeedCubit(graph<GetCommunityArticlesUseCase>()),
    );
    _registerFactoryParamIfAbsent<CommunityArticleLookupCubit, String, void>(
      graph,
      transaction,
      (articleId, _) => CommunityArticleLookupCubit(
        graph<GetCommunityArticleUseCase>(),
        articleId,
      ),
    );

    if (!graph.isRegistered<CommunitySocialRepository>()) {
      final socialDataSource = CommunitySocialFirestoreDataSource(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: firebaseFirestoreDatabaseId,
        ),
      );
      final socialRepository = CommunitySocialRepositoryImpl(socialDataSource);
      _registerSingletonIfAbsent<CommunitySocialRepository>(
        graph,
        transaction,
        () => socialRepository,
      );
    }
    _registerSingletonIfAbsent<WatchArticleLikesUseCase>(
      graph,
      transaction,
      () => WatchArticleLikesUseCase(graph<CommunitySocialRepository>()),
    );
    _registerSingletonIfAbsent<WatchArticleCommentsUseCase>(
      graph,
      transaction,
      () => WatchArticleCommentsUseCase(graph<CommunitySocialRepository>()),
    );
    _registerSingletonIfAbsent<ToggleArticleLikeUseCase>(
      graph,
      transaction,
      () => ToggleArticleLikeUseCase(graph<CommunitySocialRepository>()),
    );
    _registerSingletonIfAbsent<AddArticleCommentUseCase>(
      graph,
      transaction,
      () => AddArticleCommentUseCase(graph<CommunitySocialRepository>()),
    );
    _registerSingletonIfAbsent<DeleteArticleCommentUseCase>(
      graph,
      transaction,
      () => DeleteArticleCommentUseCase(graph<CommunitySocialRepository>()),
    );
    _registerFactoryParamIfAbsent<SocialInteractionsCubit, String, void>(
      graph,
      transaction,
      (articleId, _) => SocialInteractionsCubit(
        articleId: articleId,
        repository: graph<CommunitySocialRepository>(),
        watchLikes: graph<WatchArticleLikesUseCase>(),
        watchComments: graph<WatchArticleCommentsUseCase>(),
        toggleLike: graph<ToggleArticleLikeUseCase>(),
        addComment: graph<AddArticleCommentUseCase>(),
        deleteComment: graph<DeleteArticleCommentUseCase>(),
      ),
    );
    _registerSingletonIfAbsent<ArticleShareService>(
      graph,
      transaction,
      () => const SharePlusArticleShareService(),
    );

    _registerFactoryIfAbsent<PublishArticleCubit>(
      graph,
      transaction,
      () => PublishArticleCubit(
        graph<PublishArticleUseCase>(),
        graph<PickArticleImageUseCase>(),
      ),
    );

    transaction.registerSingleton(const _DependencyInitializationMarker());
    transaction.commit();
  } catch (error, stackTrace) {
    await transaction.rollback();
    Error.throwWithStackTrace(error, stackTrace);
  }
}
