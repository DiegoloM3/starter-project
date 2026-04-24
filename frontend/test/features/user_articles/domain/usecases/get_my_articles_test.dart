import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/get_my_articles.dart';

class _MockRepository extends Mock implements UserArticleRepository {}

void main() {
  late _MockRepository repository;
  late GetMyArticlesUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = GetMyArticlesUseCase(repository);
  });

  test('rejects empty authorId', () async {
    final result = await useCase('');
    expect(result.isLeft(), isTrue);
    verifyNever(() => repository.getMyArticles(any()));
  });

  test('forwards the list from the repository', () async {
    final articles = [
      UserArticleEntity(
        id: 'a1',
        authorId: 'u1',
        authorName: 'a',
        title: 'title',
        description: 'desc',
        content: 'content',
        thumbnailURL: 'https://x/y',
        publishedAt: DateTime(2026, 4, 24),
        updatedAt: DateTime(2026, 4, 24),
      ),
    ];
    when(() => repository.getMyArticles('u1'))
        .thenAnswer((_) async => Right(articles));

    final result = await useCase('u1');

    expect(result, Right<AppFailure, List<UserArticleEntity>>(articles));
    verify(() => repository.getMyArticles('u1')).called(1);
  });
}
