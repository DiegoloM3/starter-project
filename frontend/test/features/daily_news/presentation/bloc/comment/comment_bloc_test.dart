import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/comment/comment_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/comment/comment_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/comment/comment_state.dart';

import '../../../../../helpers/mock_classes.dart';
import '../../../../../helpers/register_fallback_values.dart';
import '../../../../../helpers/test_fixtures.dart';

void main() {
  late CommentBloc bloc;
  late MockGetCommentsUseCase mockGetComments;
  late MockAddCommentUseCase mockAddComment;
  late MockDeleteCommentUseCase mockDeleteComment;

  setUpAll(() => registerTestFallbackValues());

  setUp(() {
    mockGetComments = MockGetCommentsUseCase();
    mockAddComment = MockAddCommentUseCase();
    mockDeleteComment = MockDeleteCommentUseCase();
    bloc = CommentBloc(mockGetComments, mockAddComment, mockDeleteComment);
  });

  tearDown(() => bloc.close());

  group('initial state', () {
    test('is CommentsLoading', () {
      expect(bloc.state, isA<CommentsLoading>());
    });
  });

  group('CommentsSubscriptionRequested', () {
    test('emits [Loading, Done] with comments on DataSuccess', () async {
      final comments = testCommentList();
      final controller =
          StreamController<DataState<List<CommentEntity>>>();
      when(() => mockGetComments(params: any(named: 'params')))
          .thenAnswer((_) => controller.stream);

      final states = <CommentState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const CommentsSubscriptionRequested(tArticleId));
      await Future.delayed(Duration.zero);
      controller.add(DataSuccess(comments));
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0], isA<CommentsLoading>());
      expect(states[1], isA<CommentsDone>());
      expect((states[1] as CommentsDone).comments!.length, 3);

      verify(() => mockGetComments(params: tArticleId)).called(1);

      await sub.cancel();
      await controller.close();
    });

    test('emits [Loading, Failure] on DataFailed', () async {
      const error = AppException(message: 'fail', code: 'err');
      final controller =
          StreamController<DataState<List<CommentEntity>>>();
      when(() => mockGetComments(params: any(named: 'params')))
          .thenAnswer((_) => controller.stream);

      final states = <CommentState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const CommentsSubscriptionRequested(tArticleId));
      await Future.delayed(Duration.zero);
      controller.add(const DataFailed(error));
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0], isA<CommentsLoading>());
      expect(states[1], isA<CommentsFailure>());
      expect((states[1] as CommentsFailure).error, error);

      await sub.cancel();
      await controller.close();
    });
  });

  group('CommentAdded', () {
    test('calls add use case with comment', () async {
      final comment = testComment();
      when(() => mockAddComment(params: any(named: 'params')))
          .thenAnswer((_) async => DataSuccess(comment));

      bloc.add(CommentAdded(comment));
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockAddComment(params: any(named: 'params'))).called(1);
    });

    test('emits Failure when add returns DataFailed', () async {
      const error = AppException(message: 'fail', code: 'err');
      when(() => mockAddComment(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(error));

      bloc.add(CommentAdded(testComment()));
      await expectLater(
        bloc.stream,
        emits(isA<CommentsFailure>()),
      );

      expect((bloc.state as CommentsFailure).error, error);
    });
  });

  group('CommentDeleted', () {
    test('calls delete use case with params', () async {
      when(() => mockDeleteComment(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(null));

      bloc.add(const CommentDeleted(
        articleId: tArticleId,
        commentId: tCommentId,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockDeleteComment(params: any(named: 'params'))).called(1);
    });

    test('emits Failure when delete returns DataFailed', () async {
      const error = AppException(message: 'fail', code: 'err');
      when(() => mockDeleteComment(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(error));

      bloc.add(const CommentDeleted(
        articleId: tArticleId,
        commentId: tCommentId,
      ));
      await expectLater(
        bloc.stream,
        emits(isA<CommentsFailure>()),
      );

      expect((bloc.state as CommentsFailure).error, error);
    });
  });

  group('close', () {
    test('cancels comments stream subscription', () async {
      final controller =
          StreamController<DataState<List<CommentEntity>>>();
      when(() => mockGetComments(params: any(named: 'params')))
          .thenAnswer((_) => controller.stream);

      bloc.add(const CommentsSubscriptionRequested(tArticleId));
      await Future.delayed(Duration.zero);
      await bloc.close();

      controller.add(DataSuccess(testCommentList()));
      await controller.close();
    });
  });
}
