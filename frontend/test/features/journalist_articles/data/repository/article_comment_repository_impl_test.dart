import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/article_comment_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/signed_in_journalist.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/repository/article_comment_repository_impl.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment_draft.dart';

class MockArticleCommentRemoteDataSource extends Mock implements ArticleCommentRemoteDataSource {}

void main() {
  late MockArticleCommentRemoteDataSource dataSource;
  late ArticleCommentRepositoryImpl repository;

  final storedComment = ArticleCommentModel(
    id: 'comment1',
    content: 'Great news for the rural towns.',
    author: 'John Smith',
    authorId: 'johnSmithUid',
    createdAt: DateTime.utc(2026, 10, 2, 9, 41),
  );
  const draft = ArticleCommentDraftEntity(articleId: 'article1', content: ' Great news for the rural towns. ');

  setUp(() {
    dataSource = MockArticleCommentRemoteDataSource();
    repository = ArticleCommentRepositoryImpl(dataSource);
  });

  group('getComments', () {
    test('returns the stored comments as entities', () async {
      when(() => dataSource.getComments('article1')).thenAnswer((_) async => [storedComment]);

      final dataState = await repository.getComments('article1');

      expect(dataState.data, [storedComment.toEntity()]);
      expect(dataState.data!.single, isNot(isA<ArticleCommentModel>()));
    });

    test('returns the exception thrown by the data source as a failure', () async {
      final error = Exception('No connection');
      when(() => dataSource.getComments('article1')).thenThrow(error);

      final dataState = await repository.getComments('article1');

      expect(dataState, isA<DataFailed>());
      expect(dataState.error, error);
    });
  });

  group('addComment', () {
    test('adds the text of the comment to its article and returns it as an entity', () async {
      when(() => dataSource.addComment('article1', {'content': 'Great news for the rural towns.'}))
          .thenAnswer((_) async => storedComment);

      final dataState = await repository.addComment(draft);

      expect(dataState.data, storedComment.toEntity());
    });

    test('returns a failure when nobody is signed in', () async {
      when(() => dataSource.addComment(any(), any())).thenThrow(const NoSignedInJournalistException());

      final dataState = await repository.addComment(draft);

      expect(dataState.error, isA<NoSignedInJournalistException>());
    });
  });
}
