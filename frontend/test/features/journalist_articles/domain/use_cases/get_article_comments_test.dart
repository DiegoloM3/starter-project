import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/article_comment_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_article_comments.dart';

class MockArticleCommentRepository extends Mock implements ArticleCommentRepository {}

void main() {
  late MockArticleCommentRepository repository;
  late GetArticleCommentsUseCase getArticleComments;

  setUp(() {
    repository = MockArticleCommentRepository();
    getArticleComments = GetArticleCommentsUseCase(repository);
  });

  test('returns the comments of the article from the repository', () async {
    final comments = [
      ArticleCommentEntity(
        id: 'comment1',
        content: 'Great news for the rural towns.',
        author: 'John Smith',
        authorId: 'johnSmithUid',
        createdAt: DateTime.utc(2026, 10, 2, 9, 41),
      ),
    ];
    when(() => repository.getComments('article1')).thenAnswer((_) async => DataSuccess(comments));

    final dataState = await getArticleComments(params: 'article1');

    expect(dataState.data, comments);
  });

  test('returns the failure of the repository', () async {
    final error = Exception('No connection');
    when(() => repository.getComments('article1')).thenAnswer((_) async => DataFailed(error));

    final dataState = await getArticleComments(params: 'article1');

    expect(dataState, isA<DataFailed>());
    expect(dataState.error, error);
  });
}
