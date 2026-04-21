import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/user_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/params/list_articles_params.dart';

class ListUserArticlesUseCase
    implements UseCase<List<UserArticleEntity>, ListArticlesParams> {
  final UserArticleRepository _repository;

  ListUserArticlesUseCase(this._repository);

  @override
  Future<List<UserArticleEntity>> call({ListArticlesParams? params}) {
    final scope = params?.scope ?? UserArticlesScope.all;
    switch (scope) {
      case UserArticlesScope.mine:
        return _repository.getMyArticles();
      case UserArticlesScope.all:
        return _repository.getAllUserArticles();
    }
  }
}
