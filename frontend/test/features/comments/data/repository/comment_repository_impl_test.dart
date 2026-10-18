import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/comments/data/data_sources/remote/comment_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/comments/data/models/comment_model.dart';
import 'package:news_app_clean_architecture/features/comments/data/repository/comment_repository_impl.dart';
import 'package:news_app_clean_architecture/features/comments/domain/params/add_comment_params.dart';

class MockCommentRemoteDataSource extends Mock implements CommentRemoteDataSource {}

final comment = CommentModel(
  id: 'comment-1',
  articleId: 'article-1',
  authorId: 'user-1',
  authorName: 'Jane Doe',
  text: 'Great article',
  createdAt: DateTime(2026, 10, 17),
);

void main() {
  late MockCommentRemoteDataSource dataSource;
  late CommentRepositoryImpl repository;

  setUp(() {
    dataSource = MockCommentRemoteDataSource();
    repository = CommentRepositoryImpl(dataSource);
  });

  test('gets the comments as entities', () async {
    when(() => dataSource.getComments('article-1')).thenAnswer((_) async => [comment]);

    final result = await repository.getComments('article-1');

    expect(result.data, [comment.toEntity()]);
  });

  test('adds a comment with the trimmed text', () async {
    when(() => dataSource.addComment('article-1', 'Great article')).thenAnswer((_) async => comment);

    final result = await repository.addComment(AddCommentParams(articleId: 'article-1', text: ' Great article '));

    expect(result.data, comment.toEntity());
  });

  test('deletes a comment', () async {
    when(() => dataSource.deleteComment('article-1', 'comment-1')).thenAnswer((_) async {});

    final result = await repository.deleteComment(comment);

    expect(result, isA<DataSuccess>());
  });

  test('fails with the exception of the data source', () async {
    final error = Exception('offline');
    when(() => dataSource.getComments(any())).thenThrow(error);

    final result = await repository.getComments('article-1');

    expect(result.error, error);
  });
}
