import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_identity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/auth_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/article_comment.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_social_repository.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/social_interactions.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/social_interactions_cubit.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/screens/community_article_detail_screen.dart';

const _user = UserIdentity(
  uid: 'reader-1',
  email: 'reader@example.com',
  displayName: 'Reader',
);

const _article = CommunityArticleEntity(
  id: 'article-1',
  author: 'Reporter',
  title: 'A community article',
  description: 'A short summary.',
  url: '',
  urlToImage: '',
  publishedAt: '',
  content: 'The article body.',
  thumbnailPath: '',
  payloadHash: '',
  ownerUid: 'owner-1',
);

class _FakeSocialRepository implements CommunitySocialRepository {
  final likes = StreamController<Set<String>>.broadcast();
  final comments = StreamController<List<ArticleCommentEntity>>.broadcast();
  UserIdentity? user;
  bool? lastLikeValue;
  String? lastComment;
  String? lastDeletedComment;

  @override
  String? get currentUserId => user?.uid;

  @override
  String get currentUserName => user?.displayName ?? 'Community reader';

  @override
  Stream<Set<String>> watchLikeUserIds(String articleId) => likes.stream;

  @override
  Stream<List<ArticleCommentEntity>> watchComments(String articleId) =>
      comments.stream;

  @override
  Future<DataState<void>> setLike(
    String articleId, {
    required bool isLiked,
  }) async {
    lastLikeValue = isLiked;
    return const DataSuccess(null);
  }

  @override
  Future<DataState<void>> addComment(String articleId, String body) async {
    lastComment = body;
    return const DataSuccess(null);
  }

  @override
  Future<DataState<void>> deleteComment(
    String articleId,
    String commentId,
  ) async {
    lastDeletedComment = commentId;
    return const DataSuccess(null);
  }

  Future<void> close() async {
    await likes.close();
    await comments.close();
  }
}

class _FakeAuthRepository implements AuthRepository {
  UserIdentity? current;

  @override
  UserIdentity? get currentUser => current;

  @override
  Future<DataState<UserIdentity>> signIn(SignInParams params) async {
    current = _user;
    return const DataSuccess(_user);
  }

  @override
  Future<DataState<UserIdentity>> signUp(SignUpParams params) async {
    current = _user;
    return const DataSuccess(_user);
  }

  @override
  Future<DataState<void>> signOut() async {
    current = null;
    return const DataSuccess(null);
  }
}

SocialInteractionsCubit _createCubit(_FakeSocialRepository repository) {
  return SocialInteractionsCubit(
    articleId: _article.id,
    repository: repository,
    watchLikes: WatchArticleLikesUseCase(repository),
    watchComments: WatchArticleCommentsUseCase(repository),
    toggleLike: ToggleArticleLikeUseCase(repository),
    addComment: AddArticleCommentUseCase(repository),
    deleteComment: DeleteArticleCommentUseCase(repository),
  );
}

void main() {
  test('applies realtime likes and comments and cancels listeners on close',
      () async {
    final repository = _FakeSocialRepository()..user = _user;
    final cubit = _createCubit(repository);
    addTearDown(repository.close);

    repository.likes.add({'reader-1', 'reader-2'});
    repository.comments.add([
      const ArticleCommentEntity(
        id: 'comment-1',
        authorUid: 'reader-1',
        authorName: 'Reader',
        body: 'Useful context.',
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.likeCount, 2);
    expect(cubit.state.isLiked, isTrue);
    expect(cubit.state.comments.single.body, 'Useful context.');

    await cubit.toggleLike();
    await cubit.addComment('A follow-up.');
    await cubit.deleteComment(cubit.state.comments.single);
    expect(repository.lastLikeValue, isTrue);
    expect(repository.lastComment, 'A follow-up.');
    expect(repository.lastDeletedComment, 'comment-1');

    expect(repository.likes.hasListener, isTrue);
    await cubit.close();
    expect(repository.likes.hasListener, isFalse);
    expect(repository.comments.hasListener, isFalse);
  });

  test('refreshes own like after auth changes before toggling', () async {
    final repository = _FakeSocialRepository();
    final cubit = _createCubit(repository);
    addTearDown(cubit.close);
    addTearDown(repository.close);

    repository.likes.add({'reader-1'});
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.isLiked, isFalse);

    repository.user = _user;
    cubit.refreshLikeState();

    expect(cubit.state.isLiked, isTrue);
    await cubit.toggleLike();
    expect(repository.lastLikeValue, isTrue);
  });

  testWidgets('hides the auth prompt immediately after sign-in',
      (tester) async {
    final socialRepository = _FakeSocialRepository();
    final socialCubit = _createCubit(socialRepository);
    final authRepository = _FakeAuthRepository();
    final authCubit = AuthCubit(
      authRepository,
      SignInUseCase(authRepository),
      SignUpUseCase(authRepository),
      SignOutUseCase(authRepository),
    );
    addTearDown(socialCubit.close);
    addTearDown(socialRepository.close);
    addTearDown(authCubit.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authCubit),
          BlocProvider.value(value: socialCubit),
        ],
        child: const MaterialApp(
          home: CommunityArticleDetailScreen(article: _article),
        ),
      ),
    );
    expect(find.text('Sign in to like and comment.'), findsOneWidget);

    await authCubit.signIn('reader@example.com', 'password');
    socialRepository.user = _user;
    await tester.pump();

    expect(find.text('Sign in to like and comment.'), findsNothing);
    expect(find.text('Post comment'), findsOneWidget);
  });

  testWidgets('renders comment dates in the standard format', (tester) async {
    final socialRepository = _FakeSocialRepository()..user = _user;
    final socialCubit = _createCubit(socialRepository);
    final authRepository = _FakeAuthRepository()..current = _user;
    final authCubit = AuthCubit(
      authRepository,
      SignInUseCase(authRepository),
      SignUpUseCase(authRepository),
      SignOutUseCase(authRepository),
    );
    addTearDown(socialCubit.close);
    addTearDown(socialRepository.close);
    addTearDown(authCubit.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authCubit),
          BlocProvider.value(value: socialCubit),
        ],
        child: const MaterialApp(
          home: CommunityArticleDetailScreen(article: _article),
        ),
      ),
    );

    socialRepository.comments.add([
      ArticleCommentEntity(
        id: 'comment-1',
        authorUid: _user.uid,
        authorName: _user.displayName,
        body: 'Useful context.',
        createdAt: DateTime(2026, 9, 23, 8),
      ),
    ]);
    await tester.pump();

    expect(find.text('2026-09-23'), findsOneWidget);
    expect(find.text('23/09/2026'), findsNothing);
  });
}
