import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/comments/data/data_sources/remote/comment_firebase_service.dart';
import 'package:news_app_clean_architecture/features/comments/data/models/comment.model.dart';
import 'package:news_app_clean_architecture/features/comments/data/repository/comment_repository_impl.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.entity.dart';

class FakeCommentFirebaseService implements CommentFirebaseService {
  List<CommentModel> commentsToReturn = const [];
  bool shouldThrow = false;
  int getCalls = 0;
  int createCalls = 0;
  int deleteCalls = 0;

  @override
  Future<List<CommentModel>> getArticleComments(String articleId) async {
    getCalls++;
    if (shouldThrow) throw StateError('firestore down');
    return commentsToReturn;
  }

  @override
  Future<void> createComment(CommentModel comment) async {
    createCalls++;
    if (shouldThrow) throw StateError('firestore down');
  }

  @override
  Future<void> deleteComment(String commentId) async {
    deleteCalls++;
    if (shouldThrow) throw StateError('firestore down');
  }
}

const tModel = CommentModel(
  id: 'c1',
  articleId: 'article-1',
  authorId: 'user-1',
  authorDisplayName: 'Ada',
  content: 'Nice!',
  createdAt: '2026-09-27T00:00:00.000Z',
);

const tEntity = CommentEntity(
  articleId: 'article-1',
  authorId: 'user-1',
  authorDisplayName: 'Ada',
  content: 'Nice!',
  createdAt: '2026-09-27T00:00:00.000Z',
);

void main() {
  late FakeCommentFirebaseService fakeService;
  late CommentRepositoryImpl repository;

  setUp(() {
    fakeService = FakeCommentFirebaseService();
    repository = CommentRepositoryImpl(fakeService);
  });

  test('getArticleComments maps models to entities', () async {
    fakeService.commentsToReturn = [tModel];

    final result = await repository.getArticleComments('article-1');

    expect(result, isA<DataSuccess<List<CommentEntity>>>());
    expect(result.data?.length, 1);
    expect(result.data?.first.articleId, 'article-1');
    expect(fakeService.getCalls, 1);
  });

  test('getArticleComments returns failure when the service throws',
      () async {
    fakeService.shouldThrow = true;

    final result = await repository.getArticleComments('article-1');

    expect(result, isA<DataGenericFailed<List<CommentEntity>>>());
  });

  test('postComment delegates to the service', () async {
    final result = await repository.postComment(tEntity);

    expect(result, isA<DataSuccess<void>>());
    expect(fakeService.createCalls, 1);
  });

  test('deleteComment delegates to the service', () async {
    final result = await repository.deleteComment('c1');

    expect(result, isA<DataSuccess<void>>());
    expect(fakeService.deleteCalls, 1);
  });

  test('deleteComment returns failure when the service throws', () async {
    fakeService.shouldThrow = true;

    final result = await repository.deleteComment('c1');

    expect(result, isA<DataGenericFailed<void>>());
  });
}
