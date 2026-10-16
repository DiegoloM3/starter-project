import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/device/gallery_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_thumbnail_repository_impl.dart';

class MockGalleryService extends Mock implements GalleryService {}

void main() {
  late MockGalleryService galleryService;
  late ArticleThumbnailRepositoryImpl repository;

  setUp(() {
    galleryService = MockGalleryService();
    repository = ArticleThumbnailRepositoryImpl(galleryService);
  });

  group('ArticleThumbnailRepositoryImpl', () {
    test('returns the path of the picked image', () async {
      when(() => galleryService.pickImage()).thenAnswer((_) async => '/images/thumbnail.jpg');

      final result = await repository.pickThumbnailFromGallery();

      expect(result, isA<DataSuccess<String?>>());
      expect(result.data, '/images/thumbnail.jpg');
    });

    test('returns no path when the user closes the gallery', () async {
      when(() => galleryService.pickImage()).thenAnswer((_) async => null);

      final result = await repository.pickThumbnailFromGallery();

      expect(result, isA<DataSuccess<String?>>());
      expect(result.data, isNull);
    });

    test('returns a failure when the gallery throws', () async {
      final galleryError = Exception('Gallery unavailable');
      when(() => galleryService.pickImage()).thenThrow(galleryError);

      final result = await repository.pickThumbnailFromGallery();

      expect(result, isA<DataFailed<String?>>());
      expect(result.error, galleryError);
    });
  });
}
