import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

<<<<<<< HEAD
class RemoveArticleUseCase implements UseCase<void,ArticleEntity>{
  
  final ArticleRepository _articleRepository;

  RemoveArticleUseCase(this._articleRepository);
  
  @override
  Future<void> call({ArticleEntity ? params}) {
    return _articleRepository.removeArticle(params!);
  }
  
}
=======
class RemoveArticleUseCase extends UseCase<void, ArticleEntity> {
  final ArticleRepository _articleRepository;

  RemoveArticleUseCase(this._articleRepository);

  @override
  Future<void> call({required ArticleEntity params}) {
    return _articleRepository.removeArticle(params);
  }
}
>>>>>>> fbce432 (Finish PR (project setup))
