import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
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

  test('returns DataSuccess with saved articles', () async {
    final articles = testArticleList();
    when(() => mockRepository.getSavedArticles())
        .thenAnswer((_) async => DataSuccess(articles));

    final result = await useCase();

    expect(result, isA<DataSuccess>());
    expect(result.data, articles);
    verify(() => mockRepository.getSavedArticles()).called(1);
  });

  test('returns DataSuccess with an empty list when none saved', () async {
    when(() => mockRepository.getSavedArticles())
        .thenAnswer((_) async => DataSuccess(testArticleList(count: 0)));

    final result = await useCase();

    expect(result, isA<DataSuccess>());
    expect(result.data, isEmpty);
  });

  test('returns DataFailed when the repository fails', () async {
    const error = NetworkException(message: 'db error', code: 'db');
    when(() => mockRepository.getSavedArticles())
        .thenAnswer((_) async => const DataFailed(error));

    final result = await useCase();

    expect(result, isA<DataFailed>());
    expect(result.error, error);
  });
}
