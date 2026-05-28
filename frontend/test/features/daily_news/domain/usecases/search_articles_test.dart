import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/search_articles.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late SearchArticlesUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = SearchArticlesUseCase(mockRepository);
  });

  test('returns stream with matching articles', () {
    final articles = testArticleList();
    when(() => mockRepository.searchArticles(any()))
        .thenAnswer((_) => Stream.value(DataSuccess(articles)));

    final stream = useCase(params: 'test');

    expect(stream, emits(isA<DataSuccess>()));
    verify(() => mockRepository.searchArticles('test')).called(1);
  });

  test('passes empty string when params is null', () {
    when(() => mockRepository.searchArticles(any()))
        .thenAnswer((_) => Stream.value(const DataSuccess([])));

    useCase(params: null);

    verify(() => mockRepository.searchArticles('')).called(1);
  });
}
