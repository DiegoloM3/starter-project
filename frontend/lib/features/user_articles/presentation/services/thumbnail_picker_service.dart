/// Minimal payload returned by the platform picker — kept as a plain DTO
/// so unit tests can produce canned results without wiring image_picker.
class PickedThumbnail {
  const PickedThumbnail({
    required this.fileName,
    required this.bytes,
    required this.contentType,
  });

  final String fileName;
  final List<int> bytes;
  final String contentType;
}

/// Port implemented by the platform layer.
///
/// The editor bloc doesn't care how the bytes were obtained (camera,
/// gallery, drag-and-drop on web) — it just needs a [PickedThumbnail].
abstract class ThumbnailPickerService {
  Future<PickedThumbnail?> pickImage();
}

/// Stub used while platform integration is deferred. Returns a 1×1 PNG so
/// the end-to-end flow can run in an emulator without granting photo
/// permissions — the real picker will replace it in F8.
class StubThumbnailPickerService implements ThumbnailPickerService {
  const StubThumbnailPickerService();

  static const _onePixelPng = <int>[
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
    0,
    0,
    0,
    13,
    73,
    72,
    68,
    82,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    1,
    8,
    6,
    0,
    0,
    0,
    31,
    21,
    196,
    137,
    0,
    0,
    0,
    13,
    73,
    68,
    65,
    84,
    120,
    156,
    99,
    248,
    207,
    192,
    0,
    0,
    0,
    3,
    0,
    1,
    92,
    205,
    255,
    105,
    0,
    0,
    0,
    0,
    73,
    69,
    78,
    68,
    174,
    66,
    96,
    130,
  ];

  @override
  Future<PickedThumbnail?> pickImage() async {
    return const PickedThumbnail(
      fileName: 'stub.png',
      bytes: _onePixelPng,
      contentType: 'image/png',
    );
  }
}
