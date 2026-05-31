import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/errors/exceptions.dart';
import 'package:news_app_clean_architecture/core/errors/failure.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../domain/repository/article_image_picker_repository.dart';
import '../datasources/local/article_image_picker_data_source.dart';

@LazySingleton(as: ArticleImagePickerRepository)
class ArticleImagePickerRepositoryImpl implements ArticleImagePickerRepository {
  const ArticleImagePickerRepositoryImpl(this._dataSource);

  final ArticleImagePickerDataSource _dataSource;

  @override
  Future<DataState<File?>> pickCoverImage() async {
    try {
      return DataSuccess(await _dataSource.pickCoverImage());
    } on CacheException catch (e) {
      return DataFailed(CacheFailure(message: e.message));
    }
  }
}
