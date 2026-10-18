import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/exceptions/article_exceptions.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_draft.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_image.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/upload_article_image.dart';

import 'article_test_data.dart';

void main() {
  late MockArticleRepository repository;

  setUpAll(() => registerFallbackValue(buildValidImage()));

  setUp(() => repository = MockArticleRepository());

  test('returns the URL of the uploaded image', () async {
    final image = buildValidImage();
    when(() => repository.uploadArticleImage(image)).thenAnswer((_) async => const DataSuccess('https://img'));

    final result = await UploadArticleImageUseCase(repository).call(image);

    expect(result.data, 'https://img');
  });

  test('fails with the validation errors of an invalid image without calling the repository', () async {
    final result = await UploadArticleImageUseCase(repository).call(ArticleImage(Uint8List(0)));

    final error = result.error as ArticleValidationException;
    expect(error.errors, {ArticleValidationError.imageEmpty});
    verifyNever(() => repository.uploadArticleImage(any()));
  });
}
