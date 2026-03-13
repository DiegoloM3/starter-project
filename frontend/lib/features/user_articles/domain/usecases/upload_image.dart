import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

/// Use case for uploading an image.
class UploadImageUseCase implements UseCase<DataState<String>, File> {
  final UserArticleRepository _userArticleRepository;

  UploadImageUseCase(this._userArticleRepository);

  @override
  Future<DataState<String>> call({File? params}) async {
    if (params == null) {
      return DataFailed(Exception('Image file cannot be null'));
    }
    return await _userArticleRepository.uploadImage(params);
  }
}
