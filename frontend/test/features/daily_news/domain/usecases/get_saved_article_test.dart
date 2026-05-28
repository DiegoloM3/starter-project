import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late GetSavedArticleUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = GetSavedArticleUseCase(mockRepository);
  });

  test('returns list of saved articles', () async {
    final articles = testArticleList();
    when(() => mockRepository.getSavedArticles())
        .thenAnswer((_) async => articles);

    final result = await useCase();

    expect(result, articles);
    verify(() => mockRepository.getSavedArticles()).called(1);
  });

  test('returns empty list when no saved articles', () async {
    when(() => mockRepository.getSavedArticles())
        .thenAnswer((_) async => []);

    final result = await useCase();

    expect(result, isEmpty);
  });
}
