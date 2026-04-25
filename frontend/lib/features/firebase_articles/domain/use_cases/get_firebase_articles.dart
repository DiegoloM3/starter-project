import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/shared/article/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/repository/firebase_article_repository.dart';

class GetFirebaseArticlesUseCase implements UseCase<List<ArticleEntity>, void> {
  final FirebaseArticleRepository _repository;

  GetFirebaseArticlesUseCase(this._repository);

  @override
  Future<List<ArticleEntity>> call({void params}) {
    return _repository.getArticles();
  }
}
