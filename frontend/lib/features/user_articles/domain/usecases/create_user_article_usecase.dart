import 'dart:typed_data';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

class CreateUserArticleParams {
  final String authorName;
  final String title;
  final String description;
  final String content;
  // Null together for a draft with no cover photo yet -- a published
  // article always has both, enforced by the form's own validation before
  // this is ever called, not by these types.
  final Uint8List? thumbnailBytes;
  final String? thumbnailExtension;
  final bool isDraft;

  const CreateUserArticleParams({
    required this.authorName,
    required this.title,
    required this.description,
    required this.content,
    required this.thumbnailBytes,
    required this.thumbnailExtension,
    required this.isDraft,
  });
}

class CreateUserArticleUseCase
    implements UseCase<DataState<UserArticleEntity>, CreateUserArticleParams> {
  final UserArticleRepository _repository;

  CreateUserArticleUseCase(this._repository);

  @override
  Future<DataState<UserArticleEntity>> call(
      {CreateUserArticleParams? params}) {
    if (params == null) {
      return Future.value(DataFailed(Exception('Missing article data')));
    }
    return _repository.createArticle(
      authorName: params.authorName,
      title: params.title,
      description: params.description,
      content: params.content,
      thumbnailBytes: params.thumbnailBytes,
      thumbnailExtension: params.thumbnailExtension,
      isDraft: params.isDraft,
    );
  }
}
