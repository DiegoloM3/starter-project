import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

<<<<<<< HEAD
class GetArticleUseCase implements UseCase<DataState<List<ArticleEntity>>,void>{
  
  final ArticleRepository _articleRepository;

  GetArticleUseCase(this._articleRepository);
  
  @override
  Future<DataState<List<ArticleEntity>>> call({void params}) {
    return _articleRepository.getNewsArticles();
  }
  
}
=======
class GetArticleUseCase extends NoParamsUseCase<DataState<List<ArticleEntity>>> {
  final ArticleRepository _articleRepository;

  GetArticleUseCase(this._articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call() {
    return _articleRepository.getNewsArticles();
  }
}
>>>>>>> fbce432 (Finish PR (project setup))
