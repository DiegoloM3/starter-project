import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late GetArticleUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = GetArticleUseCase(mockRepository);
  });

  test('returns DataSuccess with list of articles on success', () async {
    final articles = testArticleList();
    when(() => mockRepository.getNewsArticles())
        .thenAnswer((_) async => DataSuccess(articles));

    final result = await useCase();

    expect(result, isA<DataSuccess>());
    expect(result.data, articles);
    verify(() => mockRepository.getNewsArticles()).called(1);
  });

  test('returns DataFailed on failure', () async {
    const error = NetworkException(message: 'No internet', code: 'timeout');
    when(() => mockRepository.getNewsArticles())
        .thenAnswer((_) async => const DataFailed(error));

    final result = await useCase();

    expect(result, isA<DataFailed>());
    expect(result.error, error);
  });
}
