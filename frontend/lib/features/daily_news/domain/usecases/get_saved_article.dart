import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

<<<<<<< HEAD
class GetSavedArticleUseCase implements UseCase<List<ArticleEntity>,void>{
  
  final ArticleRepository _articleRepository;

  GetSavedArticleUseCase(this._articleRepository);
  
  @override
  Future<List<ArticleEntity>> call({void params}) {
    return _articleRepository.getSavedArticles();
  }
  
}
=======
class GetSavedArticleUseCase extends NoParamsUseCase<List<ArticleEntity>> {
  final ArticleRepository _articleRepository;

  GetSavedArticleUseCase(this._articleRepository);

  @override
  Future<List<ArticleEntity>> call() {
    return _articleRepository.getSavedArticles();
  }
}
>>>>>>> fbce432 (Finish PR (project setup))
