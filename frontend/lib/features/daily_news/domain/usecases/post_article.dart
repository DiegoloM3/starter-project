import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class PostArticleUseCase implements UseCase<DataState<void>, ArticleEntity> {
  final ArticleRepository _articleRepository;

  PostArticleUseCase(this._articleRepository);
  
  @override
  Future<DataState<void>> call({ArticleEntity? params}) {
    return _articleRepository.postArticle(params!);
  }
}
