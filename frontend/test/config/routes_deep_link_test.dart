import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/auth_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_identity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/article_comment.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_article_lookup_repository.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_social_repository.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/get_community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/social_interactions.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_article_lookup_cubit.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/social_interactions_cubit.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/screens/community_article_deep_link_screen.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class _MissingArticleRepository implements CommunityArticleLookupRepository {
  String? requestedId;

  @override
  Future<DataState<CommunityArticleEntity?>> getPublishedArticleById(
    String articleId,
  ) async {
    requestedId = articleId;
    return const DataFailed(
      AppFailure('This article is no longer available.'),
    );
  }
}

class _LoadedArticleRepository implements CommunityArticleLookupRepository {
  const _LoadedArticleRepository();

  @override
  Future<DataState<CommunityArticleEntity?>> getPublishedArticleById(
    String articleId,
  ) async {
    return const DataSuccess(
      CommunityArticleEntity(
        id: 'shared-42',
        author: 'Reporter',
        title: 'A shared article',
        description: 'A shared article description.',
        url: '',
        urlToImage: '',
        publishedAt: '2026-09-25T08:00:00Z',
        content: 'The full shared article content.',
        thumbnailPath: '',
        payloadHash: 'hash',
        ownerUid: 'owner',
      ),
    );
  }
}

class _SocialRepository implements CommunitySocialRepository {
  const _SocialRepository();

  @override
  String? get currentUserId => null;

  @override
  String get currentUserName => 'Test user';

  @override
  Stream<Set<String>> watchLikeUserIds(String articleId) =>
      Stream.value(<String>{});

  @override
  Stream<List<ArticleCommentEntity>> watchComments(String articleId) =>
      Stream.value(const <ArticleCommentEntity>[]);

  @override
  Future<DataState<void>> setLike(
    String articleId, {
    required bool isLiked,
  }) async =>
      const DataSuccess(null);

  @override
  Future<DataState<void>> addComment(String articleId, String body) async =>
      const DataSuccess(null);

  @override
  Future<DataState<void>> deleteComment(
    String articleId,
    String commentId,
  ) async =>
      const DataSuccess(null);
}

class _AuthRepository implements AuthRepository {
  @override
  UserIdentity? get currentUser => null;

  @override
  Future<DataState<UserIdentity>> signIn(SignInParams params) async =>
      const DataFailed(AppFailure('Not available in this test.'));

  @override
  Future<DataState<UserIdentity>> signUp(SignUpParams params) async =>
      const DataFailed(AppFailure('Not available in this test.'));

  @override
  Future<DataState<void>> signOut() async => const DataSuccess(null);
}

SocialInteractionsCubit _socialCubit(String articleId) {
  const repository = _SocialRepository();
  return SocialInteractionsCubit(
    articleId: articleId,
    repository: repository,
    watchLikes: WatchArticleLikesUseCase(repository),
    watchComments: WatchArticleCommentsUseCase(repository),
    toggleLike: ToggleArticleLikeUseCase(repository),
    addComment: AddArticleCommentUseCase(repository),
    deleteComment: DeleteArticleCommentUseCase(repository),
  );
}

void main() {
  testWidgets('resolves an article query in the initial route', (tester) async {
    final repository = _MissingArticleRepository();
    await sl.reset();
    sl.registerFactoryParam<CommunityArticleLookupCubit, String, void>(
      (articleId, _) => CommunityArticleLookupCubit(
        GetCommunityArticleUseCase(repository),
        articleId,
      ),
    );
    addTearDown(sl.reset);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    Navigator.of(tester.element(find.byType(SizedBox))).push(
      AppRoutes.onGenerateRoutes(
        const RouteSettings(name: '/?article=shared-42'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.requestedId, 'shared-42');
    expect(find.text('This article is no longer available.'), findsOneWidget);
  });

  testWidgets('loaded deep link renders a single detail back button',
      (tester) async {
    await sl.reset();
    sl.registerFactoryParam<SocialInteractionsCubit, String, void>(
      (articleId, _) => _socialCubit(articleId),
    );
    addTearDown(sl.reset);

    final lookupCubit = CommunityArticleLookupCubit(
      GetCommunityArticleUseCase(const _LoadedArticleRepository()),
      'shared-42',
    )..emit(const CommunityArticleLookupLoaded(
        CommunityArticleEntity(
          id: 'shared-42',
          author: 'Reporter',
          title: 'A shared article',
          description: 'A shared article description.',
          url: '',
          urlToImage: '',
          publishedAt: '2026-09-25T08:00:00Z',
          content: 'The full shared article content.',
          thumbnailPath: '',
          payloadHash: 'hash',
          ownerUid: 'owner',
        ),
      ));
    final authCubit = AuthCubit(
      _AuthRepository(),
      SignInUseCase(_AuthRepository()),
      SignUpUseCase(_AuthRepository()),
      SignOutUseCase(_AuthRepository()),
    );
    addTearDown(lookupCubit.close);
    addTearDown(authCubit.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: lookupCubit),
          BlocProvider.value(value: authCubit),
        ],
        child: const MaterialApp(home: CommunityArticleDeepLinkScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
