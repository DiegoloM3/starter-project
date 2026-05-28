import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/register_fallback_values.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late CreateArticleUseCase useCase;
  late MockArticleRepository mockRepository;

  setUpAll(() => registerTestFallbackValues());

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = CreateArticleUseCase(mockRepository);
  });

  test('returns DataSuccess with created article', () async {
    final article = testArticle();
    when(() => mockRepository.createArticle(any()))
        .thenAnswer((_) async => DataSuccess(article));

    final result = await useCase(params: article);

    expect(result, isA<DataSuccess>());
    expect(result.data, article);
  });

  test('returns DataFailed on repository error', () async {
    const error = AppException(message: 'fail', code: 'err');
    when(() => mockRepository.createArticle(any()))
        .thenAnswer((_) async => const DataFailed(error));

    final result = await useCase(params: testArticle());

    expect(result, isA<DataFailed>());
    expect(result.error, error);
  });

  test('throws ArgumentError when params is null', () {
    expect(
      () => useCase(params: null),
      throwsA(isA<ArgumentError>()),
    );
  });
}
