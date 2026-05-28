import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_feed_articles.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late GetFeedArticlesUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = GetFeedArticlesUseCase(mockRepository);
  });

  test('returns stream that emits DataSuccess with articles', () {
    final articles = testArticleList();
    when(() => mockRepository.getFeedArticles())
        .thenAnswer((_) => Stream.value(DataSuccess(articles)));

    final stream = useCase();

    expect(stream, emits(isA<DataSuccess>()));
    verify(() => mockRepository.getFeedArticles()).called(1);
  });

  test('returns stream that emits DataFailed on error', () {
    const error = NetworkException(message: 'fail', code: 'err');
    when(() => mockRepository.getFeedArticles())
        .thenAnswer((_) => Stream.value(const DataFailed(error)));

    final stream = useCase();

    expect(stream, emits(isA<DataFailed>()));
  });

  test('delegates to repository.getFeedArticles with no params', () {
    when(() => mockRepository.getFeedArticles())
        .thenAnswer((_) => const Stream.empty());

    useCase(params: null);

    verify(() => mockRepository.getFeedArticles()).called(1);
  });
}
