import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/register_fallback_values.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late RemoveArticleUseCase useCase;
  late MockArticleRepository mockRepository;

  setUpAll(() => registerTestFallbackValues());

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = RemoveArticleUseCase(mockRepository);
  });

  test('calls repository.removeArticle with correct entity', () async {
    final article = testArticle();
    when(() => mockRepository.removeArticle(any()))
        .thenAnswer((_) async => const DataSuccess<void>(null));

    await useCase(params: article);

    verify(() => mockRepository.removeArticle(article)).called(1);
  });

  test('throws ArgumentError when params is null', () {
    expect(
      () => useCase(params: null),
      throwsA(isA<ArgumentError>()),
    );
  });
}
