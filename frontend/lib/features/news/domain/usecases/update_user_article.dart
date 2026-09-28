import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/repository/user_article_repository.dart';

/// Input required by [UpdateUserArticle]: article plus optional image.
class UpdateUserArticleParams {
  final ArticleEntity article;
  final File? imageFile;

  const UpdateUserArticleParams({
    required this.article,
    this.imageFile,
  });
}

/// Single operation: updates a user article with optional thumbnail.
class UpdateUserArticle
    implements UseCase<DataState<void>, UpdateUserArticleParams> {
  final UserArticleRepository _userArticleRepository;

  UpdateUserArticle(this._userArticleRepository);

  @override
  Future<DataState<void>> call({UpdateUserArticleParams? params}) async {
    if (params == null) {
      return Future.value(
        const DataGenericFailed('Cannot update an article without data.'),
      );
    }
    return await _userArticleRepository.updateUserArticle(
      params.article,
      imageFile: params.imageFile,
    );
  }
}
