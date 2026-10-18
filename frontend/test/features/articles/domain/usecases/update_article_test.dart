import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/exceptions/article_exceptions.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_draft.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_image.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/update_article.dart';

import 'article_test_data.dart';

void main() {
  late MockArticleRepository repository;
  late UpdateArticleUseCase updateArticle;

  setUpAll(() => registerFallbackValue(UpdateArticleParams(articleId: '', draft: buildValidDraft())));

  setUp(() {
    repository = MockArticleRepository();
    updateArticle = UpdateArticleUseCase(repository);
  });

  test('updates a valid article through the repository', () async {
    final params = UpdateArticleParams(articleId: testArticle.id, draft: buildValidDraft());
    when(() => repository.updateArticle(params)).thenAnswer((_) async => DataSuccess(testArticle));

    final result = await updateArticle(params);

    expect(result.data, testArticle);
  });

  test('fails with the validation errors of an invalid draft without calling the repository', () async {
    final params = UpdateArticleParams(articleId: testArticle.id, draft: buildInvalidDraft());

    final result = await updateArticle(params);

    final error = result.error as ArticleValidationException;
    expect(error.errors, {ArticleValidationError.titleEmpty});
    verifyNever(() => repository.updateArticle(any()));
  });

  test('fails with the validation errors of an invalid new thumbnail', () async {
    final params = UpdateArticleParams(
      articleId: testArticle.id,
      draft: buildValidDraft(),
      newThumbnail: ArticleImage(Uint8List(ArticleLimits.imageMaxBytes)),
    );

    final result = await updateArticle(params);

    final error = result.error as ArticleValidationException;
    expect(error.errors, {ArticleValidationError.imageTooLarge});
  });
}
