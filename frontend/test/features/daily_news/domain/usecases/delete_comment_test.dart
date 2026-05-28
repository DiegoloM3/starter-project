import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_comment.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late DeleteCommentUseCase useCase;
  late MockCommentRepository mockRepository;

  setUp(() {
    mockRepository = MockCommentRepository();
    useCase = DeleteCommentUseCase(mockRepository);
  });

  test('returns DataSuccess on successful delete', () async {
    when(() => mockRepository.deleteComment(
          articleId: any(named: 'articleId'),
          commentId: any(named: 'commentId'),
        )).thenAnswer((_) async => const DataSuccess(null));

    final result = await useCase(
      params: const DeleteCommentParams(
        articleId: tArticleId,
        commentId: tCommentId,
      ),
    );

    expect(result, isA<DataSuccess>());
    verify(() => mockRepository.deleteComment(
          articleId: tArticleId,
          commentId: tCommentId,
        )).called(1);
  });

  test('returns DataFailed on error', () async {
    const error = AppException(message: 'fail', code: 'err');
    when(() => mockRepository.deleteComment(
          articleId: any(named: 'articleId'),
          commentId: any(named: 'commentId'),
        )).thenAnswer((_) async => const DataFailed(error));

    final result = await useCase(
      params: const DeleteCommentParams(
        articleId: tArticleId,
        commentId: tCommentId,
      ),
    );

    expect(result, isA<DataFailed>());
  });

  test('throws ArgumentError when params is null', () {
    expect(
      () => useCase(params: null),
      throwsA(isA<ArgumentError>()),
    );
  });
}
