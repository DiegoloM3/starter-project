import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_user_articles.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late GetUserArticlesUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = GetUserArticlesUseCase(mockRepository);
  });

  test('returns stream with user articles for given userId', () {
    final articles = testArticleList();
    when(() => mockRepository.getUserArticles(any()))
        .thenAnswer((_) => Stream.value(DataSuccess(articles)));

    final stream = useCase(params: tUserId);

    expect(stream, emits(isA<DataSuccess>()));
    verify(() => mockRepository.getUserArticles(tUserId)).called(1);
  });

  test('throws ArgumentError when params is null', () {
    expect(
      () => useCase(params: null),
      throwsA(isA<ArgumentError>()),
    );
  });
}
