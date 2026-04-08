import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';

class _MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late _MockArticleRepository repository;
  late RemoveArticleUseCase useCase;

  setUp(() {
    repository = _MockArticleRepository();
    useCase = RemoveArticleUseCase(repository);
  });

  test('calls repository.removeArticle with provided article', () async {
    const article = ArticleEntity(title: 'to-remove');
    when(() => repository.removeArticle(article)).thenAnswer((_) async {});

    await useCase(params: article);

    verify(() => repository.removeArticle(article)).called(1);
  });
}
