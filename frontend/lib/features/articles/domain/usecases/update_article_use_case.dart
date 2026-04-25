import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/articles/domain/repositories/article_repository.dart';

class UpdateArticleParams {
  final ArticleEntity article;
  final File? thumbnail;

  const UpdateArticleParams({required this.article, this.thumbnail});
}

class UpdateArticleUseCase
    implements UseCase<DataState<ArticleEntity>, UpdateArticleParams> {
  final ArticleRepository _articleRepository;

  UpdateArticleUseCase(this._articleRepository);

  @override
  Future<DataState<ArticleEntity>> call({UpdateArticleParams? params}) {
    return _articleRepository.updateArticle(
      params!.article,
      thumbnail: params.thumbnail,
    );
  }
}
