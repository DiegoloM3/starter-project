import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_topic.dart';
import 'package:news_app_clean_architecture/features/articles/domain/exceptions/article_exceptions.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_draft.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_image.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/publish_article.dart';

import 'article_test_data.dart';

void main() {
  final publishArticle = PublishArticleUseCase();

  test('publishes a valid article', () async {
    final params = PublishArticleParams(draft: buildValidDraft(), thumbnail: buildValidImage());

    final result = await publishArticle(params);

    expect(result, isA<DataSuccess>());
    expect(result.data!.id, isNotEmpty);
    expect(result.data!.title, 'New title');
    expect(result.data!.topics, [ArticleTopic.sports]);
  });

  test('fails with the validation errors of an invalid draft', () async {
    final params = PublishArticleParams(draft: buildInvalidDraft(), thumbnail: buildValidImage());

    final result = await publishArticle(params);

    expect(result, isA<DataFailed>());
    final error = result.error as ArticleValidationException;
    expect(error.errors, {ArticleValidationError.titleEmpty});
  });

  test('fails with the validation errors of an invalid thumbnail', () async {
    final params = PublishArticleParams(draft: buildValidDraft(), thumbnail: ArticleImage(Uint8List(0)));

    final result = await publishArticle(params);

    final error = result.error as ArticleValidationException;
    expect(error.errors, {ArticleValidationError.imageEmpty});
  });
}
