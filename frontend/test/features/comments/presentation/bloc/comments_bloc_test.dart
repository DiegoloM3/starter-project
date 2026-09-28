import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.entity.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/delete_comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/get_article_comments.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/post_comment.dart';
import 'package:news_app_clean_architecture/features/comments/presentation/bloc/comments/comments_bloc.dart';

const tUser = UserEntity(
  id: 'user-1',
  email: 'ada@example.com',
  displayName: 'Ada',
);

const tComment = CommentEntity(
  id: 'c1',
  articleId: 'article-1',
  authorId: 'user-1',
  authorDisplayName: 'Ada',
  content: 'Nice!',
  createdAt: '2026-09-27T00:00:00.000Z',
);

class FakeGetArticleComments implements GetArticleComments {
  List<CommentEntity> commentsToReturn = const [];
  bool shouldFail = false;

  @override
  Future<DataState<List<CommentEntity>>> call({
    GetArticleCommentsParams? params,
  }) async {
    if (shouldFail) return const DataGenericFailed('load failed');
    return DataSuccess(commentsToReturn);
  }
}

class FakePostComment implements PostComment {
  bool shouldFail = false;
  int calls = 0;

  @override
  Future<DataState<void>> call({PostCommentParams? params}) async {
    calls++;
    if (params == null) return DataSuccess(null);
    if (!params.comment.hasUsableContent) {
      return const DataGenericFailed('Comment cannot be empty.');
    }
    if (shouldFail) return const DataGenericFailed('post failed');
    return DataSuccess(null);
  }
}

class FakeDeleteComment implements DeleteComment {
  bool shouldFail = false;

  @override
  Future<DataState<void>> call({DeleteCommentParams? params}) async {
    if (shouldFail) return const DataGenericFailed('delete failed');
    return DataSuccess(null);
  }
}

class FakeGetCurrentUser implements GetCurrentUserUseCase {
  UserEntity? userToReturn = tUser;

  @override
  Future<DataState<UserEntity?>> call({void params}) async {
    return DataSuccess(userToReturn);
  }
}

CommentsBloc _buildBloc({
  FakeGetArticleComments? getComments,
  FakePostComment? postComment,
  FakeDeleteComment? deleteComment,
  FakeGetCurrentUser? getCurrentUser,
}) {
  return CommentsBloc(
    getComments ?? FakeGetArticleComments(),
    postComment ?? FakePostComment(),
    deleteComment ?? FakeDeleteComment(),
    getCurrentUser ?? FakeGetCurrentUser(),
  );
}

void main() {
  test('initial state is CommentsInitial', () {
    expect(_buildBloc().state, isA<CommentsInitial>());
  });

  group('LoadComments', () {
    // Shared instance: the bloc re-emits the exact list the fake returns.
    final comments = [tComment];

    blocTest<CommentsBloc, CommentsState>(
      'emits [Loading, Loaded] with comments and viewer id',
      build: () {
        final getComments = FakeGetArticleComments()
          ..commentsToReturn = comments;
        return _buildBloc(getComments: getComments);
      },
      act: (bloc) => bloc.add(const LoadComments('article-1')),
      expect: () => [
        const CommentsLoading(),
        CommentsLoaded(comments: comments, currentUserId: 'user-1'),
      ],
    );

    blocTest<CommentsBloc, CommentsState>(
      'emits [Loading, Loaded] with null viewer id for guests',
      build: () {
        final getCurrentUser = FakeGetCurrentUser()..userToReturn = null;
        return _buildBloc(getCurrentUser: getCurrentUser);
      },
      act: (bloc) => bloc.add(const LoadComments('article-1')),
      expect: () => [
        const CommentsLoading(),
        const CommentsLoaded(comments: [], currentUserId: null),
      ],
    );

    blocTest<CommentsBloc, CommentsState>(
      'emits [Loading, Error] when loading fails',
      build: () {
        final getComments = FakeGetArticleComments()..shouldFail = true;
        return _buildBloc(getComments: getComments);
      },
      act: (bloc) => bloc.add(const LoadComments('article-1')),
      expect: () => [
        const CommentsLoading(),
        const CommentsError('load failed'),
      ],
    );
  });

  group('PostCommentRequested', () {
    final postComment = FakePostComment();
    final reloaded = [tComment];

    blocTest<CommentsBloc, CommentsState>(
      'emits [Error] for blank content without posting',
      build: () => _buildBloc(postComment: postComment),
      act: (bloc) => bloc.add(const PostCommentRequested(
        articleId: 'article-1',
        content: '   ',
      )),
      expect: () => [
        const CommentsError('Comment cannot be empty.'),
      ],
      verify: (_) => expect(postComment.calls, 0),
    );

    blocTest<CommentsBloc, CommentsState>(
      'emits [Error] when the viewer is a guest',
      build: () {
        final getCurrentUser = FakeGetCurrentUser()..userToReturn = null;
        final postComment = FakePostComment();
        return _buildBloc(
          getCurrentUser: getCurrentUser,
          postComment: postComment,
        );
      },
      act: (bloc) => bloc.add(const PostCommentRequested(
        articleId: 'article-1',
        content: 'Hello',
      )),
      expect: () => [
        const CommentsError('Please log in to comment.'),
      ],
    );

    blocTest<CommentsBloc, CommentsState>(
      'reloads the list after a successful post',
      build: () {
        final getComments = FakeGetArticleComments()
          ..commentsToReturn = reloaded;
        return _buildBloc(getComments: getComments);
      },
      act: (bloc) => bloc.add(const PostCommentRequested(
        articleId: 'article-1',
        content: 'Hello',
      )),
      expect: () => [
        CommentsLoaded(comments: reloaded, currentUserId: 'user-1'),
      ],
    );
  });

  group('DeleteCommentRequested', () {
    blocTest<CommentsBloc, CommentsState>(
      'emits [Error] when the viewer is a guest',
      build: () {
        final getCurrentUser = FakeGetCurrentUser()..userToReturn = null;
        return _buildBloc(getCurrentUser: getCurrentUser);
      },
      act: (bloc) => bloc.add(const DeleteCommentRequested(
        articleId: 'article-1',
        commentId: 'c1',
      )),
      expect: () => [
        const CommentsError('Please log in to delete your comment.'),
      ],
    );

    blocTest<CommentsBloc, CommentsState>(
      'reloads the list after a successful delete',
      build: () => _buildBloc(),
      act: (bloc) => bloc.add(const DeleteCommentRequested(
        articleId: 'article-1',
        commentId: 'c1',
      )),
      expect: () => [
        const CommentsLoaded(comments: [], currentUserId: 'user-1'),
      ],
    );
  });
}
