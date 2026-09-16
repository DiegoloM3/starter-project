import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/shared/media/data/data_sources/device/device_image_picker.dart';
import 'package:news_app_clean_architecture/shared/media/domain/entities/local_image.dart';
import 'package:news_app_clean_architecture/shared/media/domain/repository/image_picker_repository.dart';

class ImagePickerRepositoryImpl implements ImagePickerRepository {
  final DeviceImagePicker _picker;

  const ImagePickerRepositoryImpl(this._picker);

  @override
  Future<DataState<LocalImage?>> pickFromGallery() => runGuarded(
        () async => (await _picker.pickImage())?.toEntity(),
        onError: (_) => const Failure.unknown("The photo library couldn't be opened."),
      );
}
