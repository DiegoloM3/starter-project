import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_failures.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/pick_article_cover.dart';

import '../../../../helpers/article_fixtures.dart';
import '../../../../helpers/fake_cover_image_picker_repository.dart';

void main() {
  late FakeCoverImagePickerRepository repository;
  late PickArticleCoverUseCase pickCover;

  setUp(() {
    repository = FakeCoverImagePickerRepository();
    pickCover = PickArticleCoverUseCase(repository);
  });

  test('returns the image that was picked', () async {
    repository.willPick(thumbnail(fileName: 'rooftop.png'));

    final result = await pickCover(const NoParams());

    expect(result, isA<DataSuccess>());
    expect(result.data?.fileName, 'rooftop.png');
  });

  test('backing out of the gallery is not a failure', () async {
    repository.willBeCancelled();

    final result = await pickCover(const NoParams());

    // Somebody who opens the gallery and changes their mind has not done
    // anything that needs reporting.
    expect(result, isA<DataSuccess>());
    expect(result.data, isNull);
  });

  test('refuses an image the storage rules would reject, on the device',
      () async {
    repository.willPick(
      thumbnail(sizeInBytes: ArticleThumbnailEntity.maxSizeInBytes + 1),
    );

    final result = await pickCover(const NoParams());

    expect(result, isA<DataFailed>());
    expect(
      (result.error as ThumbnailValidationException).errors,
      contains(ThumbnailValidationError.fileTooLarge),
    );
  });

  test('refuses a format Cloud Storage does not accept', () async {
    repository.willPick(thumbnail(fileName: 'diagram.bmp'));

    final result = await pickCover(const NoParams());

    expect(
      (result.error as ThumbnailValidationException).errors,
      contains(ThumbnailValidationError.unsupportedFormat),
    );
  });

  test('propagates a failure from the device', () async {
    repository.pickResult = const DataFailed(FormatException('no gallery'));

    final result = await pickCover(const NoParams());

    expect(result, isA<DataFailed>());
  });
}
