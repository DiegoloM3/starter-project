import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

<<<<<<< HEAD
class SaveArticleUseCase implements UseCase<void,ArticleEntity>{
  
  final ArticleRepository _articleRepository;

  SaveArticleUseCase(this._articleRepository);
  
  @override
  Future<void> call({ArticleEntity ? params}) {
    return _articleRepository.saveArticle(params!);
  }
  
}
=======
class SaveArticleUseCase extends UseCase<void, ArticleEntity> {
  final ArticleRepository _articleRepository;

  SaveArticleUseCase(this._articleRepository);

  @override
  Future<void> call({required ArticleEntity params}) {
    return _articleRepository.saveArticle(params);
  }
}
>>>>>>> fbce432 (Finish PR (project setup))
