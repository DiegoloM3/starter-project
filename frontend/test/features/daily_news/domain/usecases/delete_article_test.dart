import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late DeleteArticleUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = DeleteArticleUseCase(mockRepository);
  });

  test('returns DataSuccess on successful delete', () async {
    when(() => mockRepository.deleteArticle(any()))
        .thenAnswer((_) async => const DataSuccess(null));

    final result = await useCase(params: tArticleId);

    expect(result, isA<DataSuccess>());
    verify(() => mockRepository.deleteArticle(tArticleId)).called(1);
  });

  test('returns DataFailed on repository error', () async {
    const error = AppException(message: 'fail', code: 'err');
    when(() => mockRepository.deleteArticle(any()))
        .thenAnswer((_) async => const DataFailed(error));

    final result = await useCase(params: tArticleId);

    expect(result, isA<DataFailed>());
  });

  test('throws ArgumentError when params is null', () {
    expect(
      () => useCase(params: null),
      throwsA(isA<ArgumentError>()),
    );
  });
}
