import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/add_article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/add_article_comment/add_article_comment_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/add_article_comment/add_article_comment_state.dart';

class MockAddArticleCommentUseCase extends Mock implements AddArticleCommentUseCase {}

void main() {
  late MockAddArticleCommentUseCase addArticleComment;
  late AddArticleCommentCubit cubit;

  const emptyDraft = ArticleCommentDraftEntity(articleId: 'article1');
  const draft = ArticleCommentDraftEntity(articleId: 'article1', content: 'Great news!');
  final addedComment = ArticleCommentEntity(
    id: 'comment1',
    content: 'Great news!',
    author: 'Jane Doe',
    authorId: 'janeDoeUid',
    createdAt: DateTime.utc(2026, 10, 2, 9, 41),
  );

  setUpAll(() => registerFallbackValue(emptyDraft));

  setUp(() {
    addArticleComment = MockAddArticleCommentUseCase();
    cubit = AddArticleCommentCubit(addArticleComment, 'article1');
  });

  tearDown(() => cubit.close());

  void stubAddResult(DataState<ArticleCommentEntity> result) {
    when(() => addArticleComment(params: any(named: 'params'))).thenAnswer((_) async => result);
  }

  test('starts with an empty comment for its article', () {
    expect(cubit.state, const AddArticleCommentEditing(emptyDraft));
  });

  test('updates the text of the comment', () {
    cubit.updateContent('Great news!');

    expect(cubit.state, const AddArticleCommentEditing(draft));
  });

  test('sends the comment and empties the draft for the next one', () async {
    stubAddResult(DataSuccess(addedComment));
    cubit.updateContent('Great news!');

    final states = expectLater(
      cubit.stream,
      emitsInOrder([const AddArticleCommentInProgress(draft), AddArticleCommentSuccess(emptyDraft, addedComment)]),
    );
    await cubit.send();
    await states;
    verify(() => addArticleComment(params: draft)).called(1);
  });

  test('keeps the text when the comment cannot be sent', () async {
    final error = Exception('No connection');
    stubAddResult(DataFailed(error));
    cubit.updateContent('Great news!');

    await cubit.send();

    expect(cubit.state, AddArticleCommentFailure(draft, error));
  });

  test('goes back to editing when the comment is blank', () async {
    stubAddResult(const DataFailed(InvalidArticleCommentDraftException(emptyDraft)));

    await cubit.send();

    expect(cubit.state, const AddArticleCommentEditing(emptyDraft));
  });

  test('does not send the same comment twice while it is being sent', () async {
    stubAddResult(DataSuccess(addedComment));
    cubit.updateContent('Great news!');

    await Future.wait([cubit.send(), cubit.send()]);

    verify(() => addArticleComment(params: draft)).called(1);
  });
}
