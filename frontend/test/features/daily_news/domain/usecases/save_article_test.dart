import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/register_fallback_values.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late SaveArticleUseCase useCase;
  late MockArticleRepository mockRepository;

  setUpAll(() => registerTestFallbackValues());

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = SaveArticleUseCase(mockRepository);
  });

  test('calls repository.saveArticle with correct entity', () async {
    final article = testArticle();
    when(() => mockRepository.saveArticle(any()))
        .thenAnswer((_) async {});

    await useCase(params: article);

    verify(() => mockRepository.saveArticle(article)).called(1);
  });

  test('throws ArgumentError when params is null', () {
    expect(
      () => useCase(params: null),
      throwsA(isA<ArgumentError>()),
    );
  });
}
