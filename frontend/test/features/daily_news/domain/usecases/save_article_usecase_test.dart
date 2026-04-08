import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';

class _MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late _MockArticleRepository repository;
  late SaveArticleUseCase useCase;

  setUp(() {
    repository = _MockArticleRepository();
    useCase = SaveArticleUseCase(repository);
  });

  test('calls repository.saveArticle with provided article', () async {
    const article = ArticleEntity(title: 'to-save');
    when(() => repository.saveArticle(article)).thenAnswer((_) async {});

    await useCase(params: article);

    verify(() => repository.saveArticle(article)).called(1);
  });
}
