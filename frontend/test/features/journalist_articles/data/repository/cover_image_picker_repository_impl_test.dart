import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/local/image_picker_service.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/repository/cover_image_picker_repository_impl.dart';

/// Stand in for the one class that reaches the device's photo library.
class _FakeImagePickerService implements ImagePickerService {
  Object? errorToThrow;

  /// Null stands for the person backing out of the picker, which the real
  /// service also reports by returning null rather than by throwing.
  PickedImage? picked;

  @override
  Future<PickedImage?> pickImage() async {
    final error = errorToThrow;

    if (error != null) {
      throw error;
    }

    return picked;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        '${invocation.memberName} is not faked',
      );
}

void main() {
  late _FakeImagePickerService picker;
  late CoverImagePickerRepositoryImpl repository;

  setUp(() {
    picker = _FakeImagePickerService();
    repository = CoverImagePickerRepositoryImpl(picker);
  });

  test('turns the picked file into a thumbnail entity', () async {
    picker.picked = PickedImage(
      fileName: 'night-bus.jpg',
      bytes: Uint8List.fromList([1, 2, 3]),
    );

    final result = await repository.pickCoverImage();

    expect(result, isA<DataSuccess>());
    expect(result.data!.fileName, 'night-bus.jpg');
    expect(result.data!.bytes, [1, 2, 3]);
  });

  /// Changing your mind is not an error. Reporting it as one would put a red
  /// message on the editor for something the journalist did on purpose.
  test('a cancelled pick is a success with nothing in it', () async {
    picker.picked = null;

    final result = await repository.pickCoverImage();

    expect(result, isA<DataSuccess>());
    expect(result.data, isNull);
  });

  test('reports a refused permission rather than throwing', () async {
    picker.errorToThrow = PlatformException(code: 'photo_access_denied');

    final result = await repository.pickCoverImage();

    expect(result, isA<DataFailed>());
    expect(result.error, isA<PlatformException>());
  });

  test('reports an unexpected error rather than throwing', () async {
    picker.errorToThrow = StateError('the plugin misbehaved');

    final result = await repository.pickCoverImage();

    expect(result, isA<DataFailed>());
    expect(result.error, isA<StateError>());
  });
}
