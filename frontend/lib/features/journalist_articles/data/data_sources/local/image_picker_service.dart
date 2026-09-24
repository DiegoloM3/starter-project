import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/core/resources/remote_exception.dart';

/// The only class in the app that reaches the device's photo library.
///
/// Plugin errors leave as [RemoteException] carrying the platform's code, so
/// the repository above never has to import the platform channels
/// (rule 1.2.4). Turning that into the domain's own failures is its job.
class ImagePickerService {
  /// Width the editor recommends for a cover.
  static const int _targetWidth = 1200;
  static const int _quality = 85;

  final ImagePicker _picker;

  const ImagePickerService(this._picker);

  /// Asks for one image and returns its name and bytes.
  ///
  /// Nothing is asked of the picker itself. `image_picker`'s own resizing
  /// decodes a single frame and re-encodes it, which turns an animated GIF
  /// into a still without saying so — so the picking stays untouched and the
  /// shrinking is decided here, per file.
  Future<PickedImage?> pickImage() async {
    final file = await _pickFromGallery();

    if (file == null) {
      return null;
    }

    final bytes = await file.readAsBytes();

    if (_isAnimated(file.name)) {
      return PickedImage(fileName: file.name, bytes: bytes);
    }

    return PickedImage(
      fileName: file.name,
      bytes: await _shrink(file.path, bytes),
    );
  }

  Future<XFile?> _pickFromGallery() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } on PlatformException catch (error) {
      throw RemoteException(
        error.code,
        message: error.message,
        cause: error,
      );
    }
  }

  /// Brings a photograph down to the size a cover is displayed at.
  ///
  /// Without this a picture straight off a phone arrives at several
  /// megabytes: it would often breach the 5 MB the storage rules allow, and
  /// every reader would download all of it to look at a 1200 pixel wide
  /// image.
  ///
  /// A failure here is not fatal — the original is returned and the size rule
  /// judges it on its merits, which is better than refusing to accept a
  /// picture because it could not be made smaller.
  Future<Uint8List> _shrink(String path, Uint8List original) async {
    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        path,
        minWidth: _targetWidth,
        minHeight: 1,
        quality: _quality,
      );

      return compressed ?? original;
    } catch (_) {
      return original;
    }
  }

  static bool _isAnimated(String fileName) =>
      fileName.toLowerCase().endsWith('.gif');
}

/// An image as it came off the device.
class PickedImage {
  final String fileName;
  final Uint8List bytes;

  const PickedImage({required this.fileName, required this.bytes});
}
