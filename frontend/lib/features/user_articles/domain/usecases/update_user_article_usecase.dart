import 'dart:typed_data';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

class UpdateUserArticleParams {
  final String id;
  final String authorName;
  final String title;
  final String description;
  final String content;
  final Uint8List? newThumbnailBytes;
  final String? newThumbnailExtension;
  final bool isDraft;

  const UpdateUserArticleParams({
    required this.id,
    required this.authorName,
    required this.title,
    required this.description,
    required this.content,
    this.newThumbnailBytes,
    this.newThumbnailExtension,
    required this.isDraft,
  });
}

class UpdateUserArticleUseCase
    implements UseCase<DataState<UserArticleEntity>, UpdateUserArticleParams> {
  final UserArticleRepository _repository;

  UpdateUserArticleUseCase(this._repository);

  @override
  Future<DataState<UserArticleEntity>> call(
      {UpdateUserArticleParams? params}) {
    if (params == null) {
      return Future.value(DataFailed(Exception('Missing article data')));
    }
    return _repository.updateArticle(
      id: params.id,
      authorName: params.authorName,
      title: params.title,
      description: params.description,
      content: params.content,
      newThumbnailBytes: params.newThumbnailBytes,
      newThumbnailExtension: params.newThumbnailExtension,
      isDraft: params.isDraft,
    );
  }
}
