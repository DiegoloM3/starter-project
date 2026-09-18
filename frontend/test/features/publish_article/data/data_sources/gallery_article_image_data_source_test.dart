import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/publish_article_result.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/publish_article_use_case.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/gallery_article_image_data_source.dart';

import '../../support/fake_publish_article_repository.dart';

GalleryArticleImagePicker pickerFor(XFile? file) => GalleryArticleImagePicker(
      pickImage: ({required source, required requestFullMetadata}) async {
        expect(source, ImageSource.gallery);
        expect(requestFullMetadata, isFalse);
        return file;
      },
    );

XFile file(String name, {String? mime}) => XFile.fromData(
      Uint8List.fromList([1, 2, 3]),
      name: name,
      path: name,
      mimeType: mime,
    );

void main() {
  test('converts bytes and name using the provided JPEG MIME', () async {
    final result =
        await pickerFor(file('photo.bin', mime: 'image/jpeg')).pickImage();
    expect(result!.fileName, 'photo.bin');
    expect(result.mimeType, 'image/jpeg');
    expect(result.bytes, [1, 2, 3]);
  });

  for (final entry in {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp'
  }.entries) {
    test('falls back to .${entry.key} case insensitively', () async {
      final result =
          await pickerFor(file('photo.${entry.key.toUpperCase()}')).pickImage();
      expect(result!.mimeType, entry.value);
    });
  }

  test('empty MIME falls back to extension', () async {
    final result = await pickerFor(file('photo.png', mime: ' ')).pickImage();
    expect(result!.mimeType, 'image/png');
  });

  test('cancellation returns null', () async {
    expect(await pickerFor(null).pickImage(), isNull);
  });

  for (final mime in <String?>['image/gif', null]) {
    test('passes unsupported MIME $mime to the domain for rejection', () async {
      final thumbnail = await pickerFor(
              file(mime == null ? 'photo.unknown' : 'photo.jpg', mime: mime))
          .pickImage();
      expect(thumbnail!.mimeType, mime ?? '');
      final result =
          await PublishArticleUseCase(FakePublishArticleRepository())(
              params: PublishArticleParams(
        author: 'Author',
        title: 'Title',
        description: 'Description',
        content: 'Content',
        thumbnail: thumbnail,
      ));
      expect(result.errors.map((error) => error.field),
          contains(PublishArticleField.thumbnailMimeType));
    });
  }

  test('propagates unexpected picker errors to the presentation', () async {
    final picker = GalleryArticleImagePicker(
        pickImage: ({required source, required requestFullMetadata}) async =>
            throw StateError('Unavailable'));
    await expectLater(picker.pickImage(), throwsStateError);
  });
}
