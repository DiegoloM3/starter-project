import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/exceptions/comment_exceptions.dart';
import 'package:news_app_clean_architecture/features/comments/domain/params/add_comment_params.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/add_comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/delete_comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/get_comments.dart';
import 'package:news_app_clean_architecture/features/comments/presentation/bloc/comments/comments_cubit.dart';
import 'package:news_app_clean_architecture/features/comments/presentation/bloc/comments/comments_state.dart';

class MockGetCommentsUseCase extends Mock implements GetCommentsUseCase {}

class MockAddCommentUseCase extends Mock implements AddCommentUseCase {}

class MockDeleteCommentUseCase extends Mock implements DeleteCommentUseCase {}

CommentEntity buildComment(String id) {
  return CommentEntity(
    id: id,
    articleId: 'article-1',
    authorId: 'user-1',
    authorName: 'Jane Doe',
    text: 'Comment $id',
    createdAt: DateTime(2026, 10, 17),
  );
}

void main() {
  late MockGetCommentsUseCase getComments;
  late MockAddCommentUseCase addComment;
  late MockDeleteCommentUseCase deleteComment;
  final oldComment = buildComment('old');
  final newComment = buildComment('new');
  final loadedState = CommentsState(status: CommentsStatus.success, comments: [oldComment]);

  setUpAll(() {
    registerFallbackValue(AddCommentParams(articleId: '', text: ''));
    registerFallbackValue(oldComment);
  });

  setUp(() {
    getComments = MockGetCommentsUseCase();
    addComment = MockAddCommentUseCase();
    deleteComment = MockDeleteCommentUseCase();
  });

  CommentsCubit buildCubit() => CommentsCubit('article-1', getComments, addComment, deleteComment);

  blocTest<CommentsCubit, CommentsState>(
    'loads the comments of the article',
    setUp: () => when(() => getComments('article-1')).thenAnswer((_) async => DataSuccess([oldComment])),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [const CommentsState(status: CommentsStatus.loading), loadedState],
  );

  blocTest<CommentsCubit, CommentsState>(
    'reports when the comments cannot be loaded',
    setUp: () => when(() => getComments('article-1')).thenAnswer((_) async => DataFailed(Exception('offline'))),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect:
        () => [
          const CommentsState(status: CommentsStatus.loading),
          const CommentsState(status: CommentsStatus.failure),
        ],
  );

  group('add', () {
    blocTest<CommentsCubit, CommentsState>(
      'shows the new comment first and reports the success',
      setUp: () => when(() => addComment(any())).thenAnswer((_) async => DataSuccess(newComment)),
      build: buildCubit,
      seed: () => loadedState,
      act: (cubit) async => expect(await cubit.add('Comment new'), isTrue),
      expect:
          () => [
            CommentsState(status: CommentsStatus.success, comments: [oldComment], isSending: true),
            CommentsState(status: CommentsStatus.success, comments: [newComment, oldComment]),
          ],
      verify: (_) {
        final params = verify(() => addComment(captureAny())).captured.single as AddCommentParams;
        expect(params.articleId, 'article-1');
      },
    );

    blocTest<CommentsCubit, CommentsState>(
      'shows the validation errors',
      setUp:
          () => when(
            () => addComment(any()),
          ).thenAnswer((_) async => const DataFailed(CommentValidationException({CommentValidationError.textEmpty}))),
      build: buildCubit,
      seed: () => loadedState,
      act: (cubit) async => expect(await cubit.add(' '), isFalse),
      expect:
          () => [
            CommentsState(status: CommentsStatus.success, comments: [oldComment], isSending: true),
            CommentsState(
              status: CommentsStatus.success,
              comments: [oldComment],
              validationErrors: const {CommentValidationError.textEmpty},
            ),
          ],
    );

    blocTest<CommentsCubit, CommentsState>(
      'reports an unexpected failure',
      setUp: () => when(() => addComment(any())).thenAnswer((_) async => DataFailed(Exception('offline'))),
      build: buildCubit,
      seed: () => loadedState,
      act: (cubit) => cubit.add('Hi'),
      expect:
          () => [
            CommentsState(status: CommentsStatus.success, comments: [oldComment], isSending: true),
            CommentsState(status: CommentsStatus.success, comments: [oldComment], failedAction: CommentsAction.add),
          ],
    );
  });

  group('delete', () {
    blocTest<CommentsCubit, CommentsState>(
      'removes the comment at once',
      setUp: () => when(() => deleteComment(oldComment)).thenAnswer((_) async => const DataSuccess(null)),
      build: buildCubit,
      seed: () => loadedState,
      act: (cubit) => cubit.delete(oldComment),
      expect: () => [const CommentsState(status: CommentsStatus.success)],
    );

    blocTest<CommentsCubit, CommentsState>(
      'restores the comment when it cannot be deleted',
      setUp: () => when(() => deleteComment(oldComment)).thenAnswer((_) async => DataFailed(Exception('offline'))),
      build: buildCubit,
      seed: () => loadedState,
      act: (cubit) => cubit.delete(oldComment),
      expect:
          () => [
            const CommentsState(status: CommentsStatus.success),
            CommentsState(status: CommentsStatus.success, comments: [oldComment], failedAction: CommentsAction.delete),
          ],
    );
  });
}
