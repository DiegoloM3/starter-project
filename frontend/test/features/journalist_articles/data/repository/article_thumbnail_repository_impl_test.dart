import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/local/article_thumbnail_gallery_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/repository/article_thumbnail_repository_impl.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';

class MockArticleThumbnailGalleryDataSource extends Mock implements ArticleThumbnailGalleryDataSource {}

void main() {
  late MockArticleThumbnailGalleryDataSource galleryDataSource;
  late ArticleThumbnailRepositoryImpl repository;

  setUp(() {
    galleryDataSource = MockArticleThumbnailGalleryDataSource();
    repository = ArticleThumbnailRepositoryImpl(galleryDataSource);
  });

  test('returns the chosen image as an entity', () async {
    final model = ArticleThumbnailModel(bytes: Uint8List(8), fileExtension: 'png');
    when(() => galleryDataSource.pickThumbnail()).thenAnswer((_) async => model);

    final dataState = await repository.pickThumbnailFromGallery();

    expect(dataState.data, model.toEntity());
    expect(dataState.data, isNot(isA<ArticleThumbnailModel>()));
  });

  test('returns no image when the gallery is closed without choosing one', () async {
    when(() => galleryDataSource.pickThumbnail()).thenAnswer((_) async => null);

    final dataState = await repository.pickThumbnailFromGallery();

    expect(dataState, isA<DataSuccess<ArticleThumbnailEntity?>>());
    expect(dataState.data, isNull);
  });

  test('returns the exception thrown by the gallery as a failure', () async {
    final error = Exception('Permission denied');
    when(() => galleryDataSource.pickThumbnail()).thenThrow(error);

    final dataState = await repository.pickThumbnailFromGallery();

    expect(dataState, isA<DataFailed>());
    expect(dataState.error, error);
  });
}
