import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/article_comment_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/add_article_comment.dart';

class MockArticleCommentRepository extends Mock implements ArticleCommentRepository {}

void main() {
  late MockArticleCommentRepository repository;
  late AddArticleCommentUseCase addArticleComment;

  const validDraft = ArticleCommentDraftEntity(articleId: 'article1', content: 'Great news for the rural towns.');
  final addedComment = ArticleCommentEntity(
    id: 'comment1',
    content: validDraft.content,
    author: 'John Smith',
    authorId: 'johnSmithUid',
    createdAt: DateTime.utc(2026, 10, 2, 9, 41),
  );

  setUpAll(() => registerFallbackValue(const ArticleCommentDraftEntity(articleId: '')));

  setUp(() {
    repository = MockArticleCommentRepository();
    addArticleComment = AddArticleCommentUseCase(repository);
  });

  test('adds a valid comment through the repository', () async {
    when(() => repository.addComment(validDraft)).thenAnswer((_) async => DataSuccess(addedComment));

    final dataState = await addArticleComment(params: validDraft);

    expect(dataState.data, addedComment);
  });

  test('does not reach the repository with a blank comment', () async {
    const blankDraft = ArticleCommentDraftEntity(articleId: 'article1', content: '  ');

    final dataState = await addArticleComment(params: blankDraft);

    expect(dataState, isA<DataFailed>());
    expect((dataState.error! as InvalidArticleCommentDraftException).draft, blankDraft);
    verifyNever(() => repository.addComment(any()));
  });

  test('returns the failure of the repository', () async {
    final error = Exception('Permission denied');
    when(() => repository.addComment(validDraft)).thenAnswer((_) async => DataFailed(error));

    final dataState = await addArticleComment(params: validDraft);

    expect(dataState.error, error);
  });
}
