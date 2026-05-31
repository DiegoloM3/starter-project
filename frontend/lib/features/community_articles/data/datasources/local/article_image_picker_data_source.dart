import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/errors/error_keys.dart';
import 'package:news_app_clean_architecture/core/errors/exceptions.dart';

/// Data source for selecting local article cover images.
///
/// This is the only community articles class that imports [image_picker].
@lazySingleton
class ArticleImagePickerDataSource {
  ArticleImagePickerDataSource(this._imagePicker);

  final ImagePicker _imagePicker;

  Future<File?> pickCoverImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        return null;
      }

      return File(image.path);
    } on PlatformException {
      throw const CacheException(CacheErrorKeys.generic);
    }
  }
}
