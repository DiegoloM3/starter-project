import 'dart:io';

import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/repository/user_article_repository.dart';

/// Input required by [CreateUserArticle]: article plus optional image.
class CreateUserArticleParams {
  final ArticleEntity article;
  final File? imageFile;

  const CreateUserArticleParams({
    required this.article,
    this.imageFile,
  });
}

/// Single operation: creates a user article with optional thumbnail.
class CreateUserArticle
    implements UseCase<DataState<void>, CreateUserArticleParams> {
  final UserArticleRepository _userArticleRepository;

  CreateUserArticle(this._userArticleRepository);

  @override
  Future<DataState<void>> call({CreateUserArticleParams? params}) async {
    if (params == null) return Future.value(DataSuccess(null));
    // Business rule: an article always carries a displayable author name.
    final name = params.article.authorDisplayName?.trim();
    final article = (name == null || name.isEmpty)
        ? ArticleEntity(
            id: params.article.id,
            authorDisplayName: kDefaultUserDisplayName,
            title: params.article.title,
            urlToImage: params.article.urlToImage,
            publishedAt: params.article.publishedAt,
            content: params.article.content,
            authorId: params.article.authorId,
          )
        : params.article;
    return await _userArticleRepository.createUserArticle(
      article,
      imageFile: params.imageFile,
    );
  }
}
