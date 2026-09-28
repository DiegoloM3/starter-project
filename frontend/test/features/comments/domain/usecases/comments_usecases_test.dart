import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.entity.dart';
import 'package:news_app_clean_architecture/features/comments/domain/repository/comment_repository.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/delete_comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/get_article_comments.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/post_comment.dart';

class FakeCommentRepository implements CommentRepository {
  List<CommentEntity> commentsToReturn = const [];
  bool shouldFail = false;
  int getCalls = 0;
  int postCalls = 0;
  int deleteCalls = 0;
  CommentEntity? lastPosted;

  @override
  Future<DataState<List<CommentEntity>>> getArticleComments(
    String articleId,
  ) async {
    getCalls++;
    if (shouldFail) return const DataGenericFailed('load failed');
    return DataSuccess(commentsToReturn);
  }

  @override
  Future<DataState<void>> postComment(CommentEntity comment) async {
    postCalls++;
    lastPosted = comment;
    if (shouldFail) return const DataGenericFailed('post failed');
    return DataSuccess(null);
  }

  @override
  Future<DataState<void>> deleteComment(String commentId) async {
    deleteCalls++;
    if (shouldFail) return const DataGenericFailed('delete failed');
    return DataSuccess(null);
  }
}

const tComment = CommentEntity(
  id: 'c1',
  articleId: 'article-1',
  authorId: 'user-1',
  authorDisplayName: 'Ada',
  content: '**Great** read!',
  createdAt: '2026-09-27T00:00:00.000Z',
);

void main() {
  late FakeCommentRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeCommentRepository();
  });

  group('GetArticleComments', () {
    test('returns repository comments for the article', () async {
      fakeRepository.commentsToReturn = [tComment];
      final usecase = GetArticleComments(fakeRepository);

      final result = await usecase(
        params: const GetArticleCommentsParams(articleId: 'article-1'),
      );

      expect(result, isA<DataSuccess<List<CommentEntity>>>());
      expect(result.data, [tComment]);
      expect(fakeRepository.getCalls, 1);
    });

    test('returns empty list without params', () async {
      final usecase = GetArticleComments(fakeRepository);

      final result = await usecase();

      expect(result, isA<DataSuccess<List<CommentEntity>>>());
      expect(result.data, isEmpty);
      expect(fakeRepository.getCalls, 0);
    });
  });

  group('PostComment', () {
    test('posts usable content to the repository', () async {
      final usecase = PostComment(fakeRepository);

      final result = await usecase(
        params: const PostCommentParams(comment: tComment),
      );

      expect(result, isA<DataSuccess<void>>());
      expect(fakeRepository.postCalls, 1);
      expect(fakeRepository.lastPosted, tComment);
    });

    test('rejects blank content without touching the repository', () async {
      const blank = CommentEntity(
        articleId: 'article-1',
        authorId: 'user-1',
        content: '   ',
        createdAt: '2026-09-27T00:00:00.000Z',
      );
      final usecase = PostComment(fakeRepository);

      final result = await usecase(
        params: const PostCommentParams(comment: blank),
      );

      expect(result, isA<DataGenericFailed<void>>());
      expect(fakeRepository.postCalls, 0);
    });
  });

  group('DeleteComment', () {
    test('deletes through the repository', () async {
      final usecase = DeleteComment(fakeRepository);

      final result = await usecase(
        params: const DeleteCommentParams(commentId: 'c1'),
      );

      expect(result, isA<DataSuccess<void>>());
      expect(fakeRepository.deleteCalls, 1);
    });

    test('propagates repository failure', () async {
      fakeRepository.shouldFail = true;
      final usecase = DeleteComment(fakeRepository);

      final result = await usecase(
        params: const DeleteCommentParams(commentId: 'c1'),
      );

      expect(result, isA<DataGenericFailed<void>>());
    });
  });
}
