import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/exceptions/article_exceptions.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_draft.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_image.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/upload_article_image.dart';

import 'article_test_data.dart';

void main() {
  final uploadArticleImage = UploadArticleImageUseCase();

  test('returns the URL of the uploaded image', () async {
    final result = await uploadArticleImage(buildValidImage());

    expect(result, isA<DataSuccess>());
    expect(Uri.parse(result.data!).isAbsolute, isTrue);
  });

  test('fails with the validation errors of an invalid image', () async {
    final result = await uploadArticleImage(ArticleImage(Uint8List(0)));

    final error = result.error as ArticleValidationException;
    expect(error.errors, {ArticleValidationError.imageEmpty});
  });
}
