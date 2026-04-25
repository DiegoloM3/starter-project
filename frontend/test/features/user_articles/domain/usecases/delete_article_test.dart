import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/delete_article.dart';

class _MockRepository extends Mock implements UserArticleRepository {}

void main() {
  late _MockRepository repository;
  late DeleteArticleUseCase useCase;

  setUpAll(() {
    registerFallbackValue(const DeleteArticleParams(id: 'stub'));
  });

  setUp(() {
    repository = _MockRepository();
    useCase = DeleteArticleUseCase(repository);
  });

  test('rejects empty id', () async {
    final result = await useCase(const DeleteArticleParams(id: ''));
    expect(result.isLeft(), isTrue);
    verifyNever(() => repository.deleteArticle(any()));
  });

  test('forwards a valid id to the repository', () async {
    when(() => repository.deleteArticle(any()))
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase(const DeleteArticleParams(id: 'a1'));

    expect(result, const Right<AppFailure, Unit>(unit));
    verify(() => repository.deleteArticle(any())).called(1);
  });
}
