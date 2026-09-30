import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/thumbnail_picker_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/pick_thumbnail_from_gallery.dart';

class MockThumbnailPickerRepository extends Mock implements ThumbnailPickerRepository {}

void main() {
  test('returns what the repository picked from the gallery', () async {
    final repository = MockThumbnailPickerRepository();
    const picked = DataSuccess<ArticleThumbnailEntity?>(ArticleThumbnailEntity(localPath: '/a.jpg', sizeInBytes: 1));
    when(() => repository.pickThumbnailFromGallery()).thenAnswer((_) async => picked);

    final result = await PickThumbnailFromGalleryUseCase(repository)();

    expect(result, same(picked));
  });
}
