import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_failures.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/params/upload_article_thumbnail_params.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/upload_article_thumbnail.dart';

import '../../../../helpers/article_fixtures.dart';
import '../../../../helpers/fake_article_thumbnail_repository.dart';

void main() {
  late FakeArticleThumbnailRepository repository;
  late UploadArticleThumbnailUseCase uploadThumbnail;

  setUp(() {
    repository = FakeArticleThumbnailRepository();
    uploadThumbnail = UploadArticleThumbnailUseCase(repository);
  });

  test('uploads a valid image and returns its url', () async {
    repository.uploadResult = const DataSuccess('https://storage/cover.jpg');

    final result = await uploadThumbnail(
      UploadArticleThumbnailParams(
        userId: 'journalist-1',
        thumbnail: thumbnail(),
      ),
    );

    expect(result, isA<DataSuccess>());
    expect(result.data, 'https://storage/cover.jpg');
    expect(repository.lastUserId, 'journalist-1');
  });

  test('never uploads an image the storage rules would reject', () async {
    final tooBig = thumbnail(
      sizeInBytes: ArticleThumbnailEntity.maxSizeInBytes + 1,
    );

    final result = await uploadThumbnail(
      UploadArticleThumbnailParams(userId: 'journalist-1', thumbnail: tooBig),
    );

    expect(result, isA<DataFailed>());
    expect(
      (result.error as ThumbnailValidationException).errors,
      contains(ThumbnailValidationError.fileTooLarge),
    );
    expect(repository.uploadCallCount, 0);
  });

  test('never uploads an unsupported format', () async {
    final result = await uploadThumbnail(
      UploadArticleThumbnailParams(
        userId: 'journalist-1',
        thumbnail: thumbnail(fileName: 'cover.bmp'),
      ),
    );

    expect(result, isA<DataFailed>());
    expect(repository.uploadCallCount, 0);
  });
}
