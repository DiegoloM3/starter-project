import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/shared/media/data/data_sources/device/device_image_picker.dart';
import 'package:news_app_clean_architecture/shared/media/data/models/local_image_model.dart';
import 'package:news_app_clean_architecture/shared/media/data/repository/image_picker_repository_impl.dart';
import 'package:news_app_clean_architecture/shared/media/domain/entities/local_image.dart';

class MockDeviceImagePicker extends Mock implements DeviceImagePicker {}

void main() {
  late MockDeviceImagePicker picker;
  late ImagePickerRepositoryImpl repository;

  setUp(() {
    picker = MockDeviceImagePicker();
    repository = ImagePickerRepositoryImpl(picker);
  });

  test('maps the picked model to an entity', () async {
    when(picker.pickImage).thenAnswer(
      (_) async => LocalImageModel.fromRawData(path: '/tmp/a.PNG', sizeInBytes: 10),
    );

    final result = await repository.pickFromGallery();

    expect(result.dataOrNull, const LocalImage(path: '/tmp/a.PNG', mimeType: 'image/png', sizeInBytes: 10));
  });

  test('a dismissed picker yields success with null', () async {
    when(picker.pickImage).thenAnswer((_) async => null);
    final result = await repository.pickFromGallery();
    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, isNull);
  });

  test('a platform error becomes an unknown failure', () async {
    when(picker.pickImage).thenThrow(Exception('no permission'));
    final result = await repository.pickFromGallery();
    expect(result.failureOrNull?.type, FailureType.unknown);
  });

  test('the model prefers the platform MIME type and guesses from the extension otherwise', () {
    expect(LocalImageModel.fromRawData(path: 'x.jpg', sizeInBytes: 1, mimeType: 'image/webp').mimeType, 'image/webp');
    expect(LocalImageModel.mimeTypeForPath('photo.jpeg'), 'image/jpeg');
    expect(LocalImageModel.mimeTypeForPath('photo.webp'), 'image/webp');
    expect(LocalImageModel.mimeTypeForPath('noextension'), 'application/octet-stream');
  });
}
