import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class CreateArticleUseCase implements UseCase<DataState<ArticleEntity>, ArticleEntity> {
  final ArticleRepository _articleRepository;

  CreateArticleUseCase(this._articleRepository);

  @override
  Future<DataState<ArticleEntity>> call({ArticleEntity? params}) {
    if (params == null) throw ArgumentError('params cannot be null');
    return _articleRepository.createArticle(params);
  }
}
