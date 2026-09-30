import 'dart:convert';
import 'dart:typed_data';

/// Removes private metadata from the images journalists publish: EXIF (GPS location, camera,
/// dates), XMP, IPTC, comments and text chunks. Thumbnails are public, so this metadata would
/// reveal where and with which device a photo was taken.
///
/// Only the JPEG orientation is kept (as a minimal EXIF block), so rotated photos are not
/// shown sideways. Formats other than JPEG, PNG and WebP are returned untouched: the publishing
/// rules reject them before upload.
class ImageMetadataRemover {
  /// Throws a [FormatException] for a truncated or invalid JPEG, PNG or WebP.
  static Uint8List removeMetadata(Uint8List image) {
    if (_startsWith(image, const [0xFF, 0xD8])) return _Jpeg.removeMetadata(image);
    if (_startsWith(image, const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) return _Png.removeMetadata(image);
    if (_isWebp(image)) return _Webp.removeMetadata(image);
    return image;
  }

  /// EXIF orientation of a JPEG (1 = upright, 6 = rotated 90° clockwise…), or `null` without EXIF.
  static int? jpegOrientationOf(Uint8List jpeg) => _Jpeg.orientationOf(jpeg);
}

bool _startsWith(Uint8List bytes, List<int> prefix) {
  if (bytes.length < prefix.length) return false;
  for (var index = 0; index < prefix.length; index++) {
    if (bytes[index] != prefix[index]) return false;
  }
  return true;
}

bool _isWebp(Uint8List bytes) {
  return bytes.length >= 12 && latin1.decode(bytes.sublist(0, 4)) == 'RIFF' && latin1.decode(bytes.sublist(8, 12)) == 'WEBP';
}

FormatException _invalid(String format) => FormatException('Truncated or invalid $format image');

class _JpegSegment {
  final int marker;
  final Uint8List bytes;

  const _JpegSegment(this.marker, this.bytes);
}

abstract final class _Jpeg {
  static const int _app0Jfif = 0xE0;
  static const int _app1Exif = 0xE1;
  static const int _startOfScan = 0xDA;
  static const int _fillByte = 0xFF;
  // APP1 (EXIF, XMP), APP12, APP13 (IPTC) and comments. ICC profiles (APP2) and Adobe color
  // information (APP14) are kept: they only describe colors.
  static const Set<int> _metadataMarkers = {0xE1, 0xEC, 0xED, 0xFE};
  static final Uint8List _exifHeader = latin1.encode('Exif\x00\x00');

  static Uint8List removeMetadata(Uint8List jpeg) {
    final (:segments, :scanStart) = _parse(jpeg);
    final orientation = _orientationIn(segments);
    final kept = segments.where((segment) => !_metadataMarkers.contains(segment.marker)).toList();
    final hasJfif = kept.isNotEmpty && kept.first.marker == _app0Jfif;
    final output = BytesBuilder(copy: false)..add(jpeg.sublist(0, 2));
    if (hasJfif) output.add(kept.first.bytes);
    if (orientation != null && orientation != 1) output.add(_orientationOnlyExif(orientation));
    for (final segment in kept.skip(hasJfif ? 1 : 0)) {
      output.add(segment.bytes);
    }
    output.add(Uint8List.sublistView(jpeg, scanStart));
    return output.toBytes();
  }

  static int? orientationOf(Uint8List jpeg) => _orientationIn(_parse(jpeg).segments);

  /// Segments before the compressed image data, which starts at [scanStart] and is copied as is.
  static ({List<_JpegSegment> segments, int scanStart}) _parse(Uint8List jpeg) {
    final segments = <_JpegSegment>[];
    var offset = 2;
    while (true) {
      if (offset + 4 > jpeg.length || jpeg[offset] != 0xFF) throw _invalid('JPEG');
      final marker = jpeg[offset + 1];
      if (marker == _fillByte) {
        offset++;
        continue;
      }
      if (marker == _startOfScan) return (segments: segments, scanStart: offset);
      final end = offset + 2 + ByteData.sublistView(jpeg, offset + 2, offset + 4).getUint16(0);
      if (end > jpeg.length) throw _invalid('JPEG');
      segments.add(_JpegSegment(marker, Uint8List.sublistView(jpeg, offset, end)));
      offset = end;
    }
  }

  static int? _orientationIn(List<_JpegSegment> segments) {
    final exif = segments.where(_isExif).firstOrNull;
    if (exif == null) return null;
    return _Tiff.orientationOf(Uint8List.sublistView(exif.bytes, 4 + _exifHeader.length));
  }

  static bool _isExif(_JpegSegment segment) {
    if (segment.marker != _app1Exif || segment.bytes.length < 4 + _exifHeader.length) return false;
    return _startsWith(Uint8List.sublistView(segment.bytes, 4), _exifHeader);
  }

  static Uint8List _orientationOnlyExif(int orientation) {
    final payload = [..._exifHeader, ..._Tiff.withOnlyOrientation(orientation)];
    final length = payload.length + 2;
    return Uint8List.fromList([0xFF, _app1Exif, length >> 8, length & 0xFF, ...payload]);
  }
}

abstract final class _Tiff {
  static const int _orientationTag = 0x0112;
  static const int _shortType = 3;

  static int? orientationOf(Uint8List tiff) {
    if (tiff.length < 8) return null;
    final endian = tiff[0] == 0x49 ? Endian.little : Endian.big; // "II" or "MM"
    final data = ByteData.sublistView(tiff);
    final firstDirectory = data.getUint32(4, endian);
    if (firstDirectory + 2 > tiff.length) return null;
    final entries = data.getUint16(firstDirectory, endian);
    for (var index = 0; index < entries; index++) {
      final entry = firstDirectory + 2 + index * 12;
      if (entry + 12 > tiff.length) return null;
      if (data.getUint16(entry, endian) == _orientationTag) return data.getUint16(entry + 8, endian);
    }
    return null;
  }

  /// A little-endian TIFF block whose only entry is the orientation.
  static Uint8List withOnlyOrientation(int orientation) {
    final tiff = ByteData(26)
      ..setUint16(0, 0x4949) // "II": little-endian
      ..setUint16(2, 42, Endian.little)
      ..setUint32(4, 8, Endian.little) // first directory right after the header
      ..setUint16(8, 1, Endian.little) // one entry
      ..setUint16(10, _orientationTag, Endian.little)
      ..setUint16(12, _shortType, Endian.little)
      ..setUint32(14, 1, Endian.little) // one value
      ..setUint16(18, orientation, Endian.little)
      ..setUint32(22, 0, Endian.little); // no further directories
    return tiff.buffer.asUint8List();
  }
}

abstract final class _Png {
  static const Set<String> _metadataChunks = {'eXIf', 'tEXt', 'zTXt', 'iTXt', 'tIME'};

  static Uint8List removeMetadata(Uint8List png) {
    final output = BytesBuilder(copy: false)..add(png.sublist(0, 8));
    var offset = 8;
    while (offset + 12 <= png.length) {
      final end = offset + 12 + ByteData.sublistView(png, offset, offset + 4).getUint32(0);
      if (end > png.length) throw _invalid('PNG');
      final type = latin1.decode(png.sublist(offset + 4, offset + 8));
      if (!_metadataChunks.contains(type)) output.add(Uint8List.sublistView(png, offset, end));
      offset = end;
    }
    return output.toBytes();
  }
}

abstract final class _Webp {
  static const Set<String> _metadataChunks = {'EXIF', 'XMP '};
  static const int _exifAndXmpFlags = 0x08 | 0x04;

  static Uint8List removeMetadata(Uint8List webp) {
    final chunks = BytesBuilder(copy: false);
    var offset = 12;
    while (offset + 8 <= webp.length) {
      final size = ByteData.sublistView(webp, offset + 4, offset + 8).getUint32(0, Endian.little);
      final end = offset + 8 + size + (size.isOdd ? 1 : 0);
      if (end > webp.length) throw _invalid('WebP');
      final fourCc = latin1.decode(webp.sublist(offset, offset + 4));
      if (!_metadataChunks.contains(fourCc)) chunks.add(_withoutMetadataFlags(fourCc, webp.sublist(offset, end)));
      offset = end;
    }
    return _riff(chunks.toBytes());
  }

  static Uint8List _withoutMetadataFlags(String fourCc, Uint8List chunk) {
    if (fourCc == 'VP8X') chunk[8] &= ~_exifAndXmpFlags;
    return chunk;
  }

  static Uint8List _riff(Uint8List chunks) {
    final size = ByteData(4)..setUint32(0, chunks.length + 4, Endian.little);
    return Uint8List.fromList([...latin1.encode('RIFF'), ...size.buffer.asUint8List(), ...latin1.encode('WEBP'), ...chunks]);
  }
}
