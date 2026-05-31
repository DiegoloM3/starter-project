import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../repository/article_image_picker_repository.dart';

class PickCoverImageUseCase implements UseCase<DataState<File?>, void> {
  const PickCoverImageUseCase(this._repository);

  final ArticleImagePickerRepository _repository;

  @override
  Future<DataState<File?>> call({void params}) => _repository.pickCoverImage();
}
