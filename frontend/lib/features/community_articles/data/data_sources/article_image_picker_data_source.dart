import 'package:image_picker/image_picker.dart';

import '../../domain/entities/article_image.dart';

class ArticleImagePickerDataSource {
  final ImagePicker _picker;

  ArticleImagePickerDataSource([ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  Future<ArticleImageEntity?> pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final provisionalMime = _mimeForBytes(bytes);
    if (provisionalMime == null) {
      throw const FormatException('Select a JPEG, PNG, or WebP image.');
    }
    return ArticleImageEntity(
      bytes: bytes,
      fileName: file.name,
      mimeType: provisionalMime,
    );
  }

  String? _mimeForBytes(List<int> bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    const png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    if (bytes.length >= png.length &&
        Iterable.generate(png.length, (index) => bytes[index] == png[index])
            .every((value) => value)) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return 'image/webp';
    }
    return null;
  }
}
