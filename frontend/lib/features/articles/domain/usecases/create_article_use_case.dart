import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/articles/domain/repositories/article_repository.dart';

class CreateArticleParams {
  final ArticleEntity article;
  final File? thumbnail;

  const CreateArticleParams({required this.article, this.thumbnail});
}

class CreateArticleUseCase
    implements UseCase<DataState<ArticleEntity>, CreateArticleParams> {
  final ArticleRepository _articleRepository;

  CreateArticleUseCase(this._articleRepository);

  @override
  Future<DataState<ArticleEntity>> call({CreateArticleParams? params}) {
    return _articleRepository.createArticle(
      params!.article,
      thumbnail: params.thumbnail,
    );
  }
}
