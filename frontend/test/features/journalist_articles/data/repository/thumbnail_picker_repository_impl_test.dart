import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/local/gallery_image_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/repository/thumbnail_picker_repository_impl.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';

class MockGalleryImageDataSource extends Mock implements GalleryImageDataSource {}

void main() {
  late MockGalleryImageDataSource dataSource;
  late ThumbnailPickerRepositoryImpl repository;

  setUp(() {
    dataSource = MockGalleryImageDataSource();
    repository = ThumbnailPickerRepositoryImpl(dataSource);
  });

  test('returns the picked image as an entity, not a model', () async {
    when(() => dataSource.pickImage()).thenAnswer(
      (_) async => ArticleThumbnailModel.fromRawData(localPath: '/gallery/photo.png', sizeInBytes: 10),
    );

    final result = await repository.pickThumbnailFromGallery();

    expect(result, isA<DataSuccess<ArticleThumbnailEntity?>>());
    expect(result.data.runtimeType, ArticleThumbnailEntity);
    expect(result.data, const ArticleThumbnailEntity(localPath: '/gallery/photo.png', sizeInBytes: 10));
  });

  test('succeeds without a thumbnail when the journalist cancels', () async {
    when(() => dataSource.pickImage()).thenAnswer((_) async => null);

    final result = await repository.pickThumbnailFromGallery();

    expect(result, isA<DataSuccess<ArticleThumbnailEntity?>>());
    expect(result.data, isNull);
  });

  test('fails when the gallery cannot be opened', () async {
    final error = PlatformException(code: 'photo_access_denied');
    when(() => dataSource.pickImage()).thenThrow(error);

    final result = await repository.pickThumbnailFromGallery();

    expect(result, isA<DataFailed<ArticleThumbnailEntity?>>());
    expect(result.error, same(error));
  });
}
