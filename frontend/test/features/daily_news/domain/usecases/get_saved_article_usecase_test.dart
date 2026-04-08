import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';

class _MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late _MockArticleRepository repository;
  late GetSavedArticleUseCase useCase;

  setUp(() {
    repository = _MockArticleRepository();
    useCase = GetSavedArticleUseCase(repository);
  });

  test('calls repository.getSavedArticles', () async {
    const expected = <ArticleEntity>[ArticleEntity(title: 'saved')];
    when(() => repository.getSavedArticles()).thenAnswer((_) async => expected);

    final result = await useCase();

    expect(result, expected);
    verify(() => repository.getSavedArticles()).called(1);
  });
}
