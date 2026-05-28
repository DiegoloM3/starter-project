import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/register_fallback_values.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late UpdateArticleUseCase useCase;
  late MockArticleRepository mockRepository;

  setUpAll(() => registerTestFallbackValues());

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = UpdateArticleUseCase(mockRepository);
  });

  test('returns DataSuccess with updated article', () async {
    final article = testArticle(title: 'Updated');
    when(() => mockRepository.updateArticle(any()))
        .thenAnswer((_) async => DataSuccess(article));

    final result = await useCase(params: article);

    expect(result, isA<DataSuccess>());
    expect(result.data!.title, 'Updated');
  });

  test('returns DataFailed on repository error', () async {
    const error = AppException(message: 'fail', code: 'err');
    when(() => mockRepository.updateArticle(any()))
        .thenAnswer((_) async => const DataFailed(error));

    final result = await useCase(params: testArticle());

    expect(result, isA<DataFailed>());
  });

  test('throws ArgumentError when params is null', () {
    expect(
      () => useCase(params: null),
      throwsA(isA<ArgumentError>()),
    );
  });
}
