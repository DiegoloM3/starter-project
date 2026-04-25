import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/repository/firebase_article_repository.dart';
import 'package:news_app_clean_architecture/shared/article/domain/entities/article.dart';

class CreateArticleUseCase
    implements UseCase<ArticleEntity, CreateArticleParams> {
  final FirebaseArticleRepository _repository;

  CreateArticleUseCase(this._repository);

  @override
  Future<ArticleEntity> call({CreateArticleParams? params}) {
    return _repository.createArticle(params!);
  }
}
