import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/exceptions/article_exceptions.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_draft.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_image.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_articles.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/update_article.dart';

import 'article_test_data.dart';

void main() {
  final updateArticle = UpdateArticleUseCase();

  Future<String> existingArticleId() async =>
      (await GetArticlesUseCase().call(const NoParams())).data!.first.id;

  test('updates the editable fields and keeps the authorship and publication date', () async {
    final original = (await GetArticlesUseCase().call(const NoParams())).data!.first;
    final params = UpdateArticleParams(articleId: original.id, draft: buildValidDraft());

    final result = await updateArticle(params);

    expect(result, isA<DataSuccess>());
    expect(result.data!.title, 'New title');
    expect(result.data!.authorId, original.authorId);
    expect(result.data!.publishedAt, original.publishedAt);
    expect(result.data!.thumbnailURL, original.thumbnailURL);
  });

  test('fails with the validation errors of an invalid draft', () async {
    final params = UpdateArticleParams(articleId: await existingArticleId(), draft: buildInvalidDraft());

    final result = await updateArticle(params);

    final error = result.error as ArticleValidationException;
    expect(error.errors, {ArticleValidationError.titleEmpty});
  });

  test('fails with the validation errors of an invalid new thumbnail', () async {
    final params = UpdateArticleParams(
      articleId: await existingArticleId(),
      draft: buildValidDraft(),
      newThumbnail: ArticleImage(Uint8List(ArticleLimits.imageMaxBytes)),
    );

    final result = await updateArticle(params);

    final error = result.error as ArticleValidationException;
    expect(error.errors, {ArticleValidationError.imageTooLarge});
  });

  test('fails when the article does not exist', () async {
    final params = UpdateArticleParams(articleId: 'missing', draft: buildValidDraft());

    final result = await updateArticle(params);

    expect(result.error, isA<ArticleNotFoundException>());
  });
}
