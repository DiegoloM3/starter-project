import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/device/gallery_service.dart';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late MockImagePicker imagePicker;
  late GalleryService galleryService;

  setUpAll(() {
    registerFallbackValue(ImageSource.gallery);
  });

  setUp(() {
    imagePicker = MockImagePicker();
    galleryService = GalleryService(imagePicker);
  });

  void stubPickedImage(XFile? image) {
    when(() => imagePicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          imageQuality: any(named: 'imageQuality'),
        )).thenAnswer((_) async => image);
  }

  group('GalleryService', () {
    test('picks a resized and compressed image from the gallery', () async {
      stubPickedImage(XFile('/images/thumbnail.jpg'));

      final path = await galleryService.pickImage();

      expect(path, '/images/thumbnail.jpg');
      verify(() => imagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: GalleryService.maxImageWidth,
            imageQuality: GalleryService.imageQuality,
          )).called(1);
    });

    test('returns no path when the user closes the gallery', () async {
      stubPickedImage(null);

      expect(await galleryService.pickImage(), isNull);
    });

    test('lets errors from the gallery propagate', () async {
      when(() => imagePicker.pickImage(
            source: any(named: 'source'),
            maxWidth: any(named: 'maxWidth'),
            imageQuality: any(named: 'imageQuality'),
          )).thenThrow(Exception('Gallery unavailable'));

      expect(galleryService.pickImage(), throwsException);
    });
  });
}
