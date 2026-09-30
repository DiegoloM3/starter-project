import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/local/gallery_image_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/local/image_metadata_remover.dart';

import '../../../../../fixtures/images_with_metadata.dart';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late MockImagePicker imagePicker;
  late GalleryImageDataSource dataSource;
  late Directory pickerCache;

  setUpAll(() => registerFallbackValue(ImageSource.gallery));

  setUp(() async {
    imagePicker = MockImagePicker();
    dataSource = GalleryImageDataSource(imagePicker);
    pickerCache = await Directory.systemTemp.createTemp('image_picker');
  });

  tearDown(() => pickerCache.delete(recursive: true));

  void givenPickedFile(XFile? file) {
    when(() => imagePicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
          requestFullMetadata: any(named: 'requestFullMetadata'),
        )).thenAnswer((_) async => file);
  }

  Future<File> photoFromCamera() async {
    return File('${pickerCache.path}/IMG_0001.jpg').writeAsBytes(jpegRotatedWithMetadata);
  }

  test('opens the gallery only, never the camera', () async {
    givenPickedFile(null);

    await dataSource.pickImage();

    final source = verify(() => imagePicker.pickImage(
          source: captureAny(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
          requestFullMetadata: any(named: 'requestFullMetadata'),
        )).captured.single;
    expect(source, ImageSource.gallery);
  });

  test('returns a copy of the photo without its location, camera or dates', () async {
    givenPickedFile(XFile((await photoFromCamera()).path));

    final thumbnail = await dataSource.pickImage();

    final published = await File(thumbnail!.localPath).readAsBytes();
    expect(latin1.decode(published), isNot(contains('SecretCam')));
    expect(ImageMetadataRemover.jpegOrientationOf(published), 6);
    expect(thumbnail.sizeInBytes, published.length);
    expect(thumbnail.localPath, endsWith('.jpg'));
  });

  test('never modifies the picked file itself', () async {
    final picked = await photoFromCamera();
    givenPickedFile(XFile(picked.path));

    final thumbnail = await dataSource.pickImage();

    expect(thumbnail!.localPath, isNot(picked.path));
    expect(await picked.readAsBytes(), jpegRotatedWithMetadata);
  });

  test('returns null when the journalist cancels', () async {
    givenPickedFile(null);

    expect(await dataSource.pickImage(), isNull);
  });

  test('fails instead of returning an image whose metadata could not be removed', () async {
    final corrupted = await File('${pickerCache.path}/broken.jpg').writeAsBytes(jpegRotatedWithMetadata.sublist(0, 30));
    givenPickedFile(XFile(corrupted.path));

    expect(dataSource.pickImage, throwsFormatException);
  });
}
