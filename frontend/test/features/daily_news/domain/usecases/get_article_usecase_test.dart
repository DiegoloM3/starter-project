import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';

class _MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late _MockArticleRepository repository;
  late GetArticleUseCase useCase;

  setUp(() {
    repository = _MockArticleRepository();
    useCase = GetArticleUseCase(repository);
  });

  test('calls repository.getNewsArticles and returns DataState', () async {
    const articles = <ArticleEntity>[ArticleEntity(title: 't1')];
    const expected = DataSuccess<List<ArticleEntity>>(articles);
    when(() => repository.getNewsArticles()).thenAnswer((_) async => expected);

    final result = await useCase();

    expect(result, expected);
    verify(() => repository.getNewsArticles()).called(1);
  });
}
