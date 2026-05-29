import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/action/article_action_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/action/article_action_state.dart';

import '../../../../../../helpers/mock_classes.dart';
import '../../../../../../helpers/test_fixtures.dart';

void main() {
  late ArticleActionCubit cubit;
  late MockDeleteArticleUseCase mockDelete;

  setUp(() {
    mockDelete = MockDeleteArticleUseCase();
    cubit = ArticleActionCubit(mockDelete);
  });

  tearDown(() => cubit.close());

  group('initial state', () {
    test('is ArticleActionInitial', () {
      expect(cubit.state, isA<ArticleActionInitial>());
    });
  });

  group('deleteArticle', () {
    test('emits [InProgress, DeleteSuccess] on successful delete', () async {
      when(() => mockDelete(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(null));

      // Subscribe before triggering: deleteArticle emits ArticleActionInProgress
      // synchronously, so the expectation must be set up first. Await it after
      // the action so a failed expectation fails this test deterministically.
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ArticleActionInProgress>(),
          isA<ArticleActionDeleteSuccess>(),
        ]),
      );

      await cubit.deleteArticle(tArticleId);
      await expectation;
      verify(() => mockDelete(params: tArticleId)).called(1);
    });

    test('emits [InProgress, Failure] on failed delete', () async {
      const error = AppException(message: 'Unauthorized', code: 'auth');
      when(() => mockDelete(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(error));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ArticleActionInProgress>(),
          isA<ArticleActionFailure>(),
        ]),
      );

      await cubit.deleteArticle(tArticleId);
      await expectation;

      final state = cubit.state as ArticleActionFailure;
      expect(state.error.message, 'Unauthorized');
    });
  });
}
