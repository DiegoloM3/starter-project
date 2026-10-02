import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_article_comments.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_comments/article_comments_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_comments/article_comments_state.dart';

class MockGetArticleCommentsUseCase extends Mock implements GetArticleCommentsUseCase {}

ArticleCommentEntity buildComment(String id, String author) {
  return ArticleCommentEntity(
    id: id,
    content: 'A comment by $author.',
    author: author,
    authorId: '${author}Uid',
    createdAt: DateTime.utc(2026, 10, 2, 9, 41),
  );
}

void main() {
  late MockGetArticleCommentsUseCase getArticleComments;
  late ArticleCommentsCubit cubit;

  final comments = [buildComment('comment1', 'John Smith')];
  final newComment = buildComment('comment2', 'Jane Doe');

  setUp(() {
    getArticleComments = MockGetArticleCommentsUseCase();
    cubit = ArticleCommentsCubit(getArticleComments, 'article1');
  });

  tearDown(() => cubit.close());

  void stubComments(DataState<List<ArticleCommentEntity>> result) {
    when(() => getArticleComments(params: 'article1')).thenAnswer((_) async => result);
  }

  test('starts loading the comments', () {
    expect(cubit.state, const ArticleCommentsInProgress());
  });

  test('shows the comments of its article', () async {
    stubComments(DataSuccess(comments));

    final states = expectLater(
      cubit.stream,
      emitsInOrder([const ArticleCommentsInProgress(), ArticleCommentsSuccess(comments)]),
    );
    await cubit.loadComments();
    await states;
  });

  test('shows a failure when the comments cannot be loaded', () async {
    final error = Exception('No connection');
    stubComments(DataFailed(error));

    await cubit.loadComments();

    expect(cubit.state, ArticleCommentsFailure(error));
  });

  test('refreshes the comments without going back to loading', () async {
    stubComments(DataSuccess(comments));
    await cubit.loadComments();
    stubComments(DataSuccess([...comments, newComment]));

    final states = expectLater(cubit.stream, emitsInOrder([ArticleCommentsSuccess([...comments, newComment])]));
    await cubit.loadComments();
    await states;
  });

  test('adds the comment the journalist has just written at the end', () async {
    stubComments(DataSuccess(comments));
    await cubit.loadComments();

    cubit.showAddedComment(newComment);

    expect(cubit.state, ArticleCommentsSuccess([...comments, newComment]));
  });

  test('reads the comments again when a comment is added before they could be loaded', () async {
    stubComments(DataFailed(Exception('No connection')));
    await cubit.loadComments();
    stubComments(DataSuccess([...comments, newComment]));

    cubit.showAddedComment(newComment);
    await pumpEventQueue();

    expect(cubit.state, ArticleCommentsSuccess([...comments, newComment]));
  });
}
