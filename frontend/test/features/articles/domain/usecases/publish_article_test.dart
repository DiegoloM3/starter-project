import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/exceptions/article_exceptions.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_draft.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_image.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/publish_article.dart';

import 'article_test_data.dart';

void main() {
  late MockArticleRepository repository;
  late PublishArticleUseCase publishArticle;

  setUpAll(() => registerFallbackValue(PublishArticleParams(draft: buildValidDraft(), thumbnail: buildValidImage())));

  setUp(() {
    repository = MockArticleRepository();
    publishArticle = PublishArticleUseCase(repository);
  });

  test('publishes a valid article through the repository', () async {
    final params = PublishArticleParams(draft: buildValidDraft(), thumbnail: buildValidImage());
    when(() => repository.publishArticle(params)).thenAnswer((_) async => DataSuccess(testArticle));

    final result = await publishArticle(params);

    expect(result.data, testArticle);
  });

  test('fails with the validation errors of an invalid draft without calling the repository', () async {
    final params = PublishArticleParams(draft: buildInvalidDraft(), thumbnail: buildValidImage());

    final result = await publishArticle(params);

    final error = result.error as ArticleValidationException;
    expect(error.errors, {ArticleValidationError.titleEmpty});
    verifyNever(() => repository.publishArticle(any()));
  });

  test('fails with the validation errors of an invalid thumbnail', () async {
    final params = PublishArticleParams(draft: buildValidDraft(), thumbnail: ArticleImage(Uint8List(0)));

    final result = await publishArticle(params);

    final error = result.error as ArticleValidationException;
    expect(error.errors, {ArticleValidationError.imageEmpty});
  });
}
