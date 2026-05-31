import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';

abstract interface class ArticleImagePickerRepository {
  Future<DataState<File?>> pickCoverImage();
}
