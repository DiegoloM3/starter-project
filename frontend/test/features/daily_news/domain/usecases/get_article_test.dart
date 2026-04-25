import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
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

  group('GetArticleUseCase', () {
    test('forwards the Right list from the repository', () async {
      const articles = [ArticleEntity(id: 1, title: 'hello')];
      when(repository.getNewsArticles)
          .thenAnswer((_) async => const Right(articles));

      final result = await useCase(const NoParams());

      expect(result, const Right<AppFailure, List<ArticleEntity>>(articles));
      verify(repository.getNewsArticles).called(1);
    });

    test('forwards the Left failure from the repository', () async {
      const failure = AppFailure.network(message: 'boom');
      when(repository.getNewsArticles)
          .thenAnswer((_) async => const Left(failure));

      final result = await useCase(const NoParams());

      expect(result, const Left<AppFailure, List<ArticleEntity>>(failure));
    });
  });
}
