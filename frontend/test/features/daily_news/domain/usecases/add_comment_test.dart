import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/add_comment.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/register_fallback_values.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late AddCommentUseCase useCase;
  late MockCommentRepository mockRepository;

  setUpAll(() => registerTestFallbackValues());

  setUp(() {
    mockRepository = MockCommentRepository();
    useCase = AddCommentUseCase(mockRepository);
  });

  test('returns DataSuccess with created comment', () async {
    final comment = testComment();
    when(() => mockRepository.addComment(any()))
        .thenAnswer((_) async => DataSuccess(comment));

    final result = await useCase(params: comment);

    expect(result, isA<DataSuccess>());
    expect(result.data, comment);
  });

  test('returns DataFailed on error', () async {
    const error = AppException(message: 'fail', code: 'err');
    when(() => mockRepository.addComment(any()))
        .thenAnswer((_) async => const DataFailed(error));

    final result = await useCase(params: testComment());

    expect(result, isA<DataFailed>());
  });

  test('throws ArgumentError when params is null', () {
    expect(
      () => useCase(params: null),
      throwsA(isA<ArgumentError>()),
    );
  });
}
