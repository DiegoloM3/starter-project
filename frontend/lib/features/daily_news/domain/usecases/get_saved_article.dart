import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/local_article_repository.dart';

class GetSavedArticleUseCase
    implements UseCase<DataState<List<ArticleEntity>>, void> {
  final LocalArticleRepository _repository;

  GetSavedArticleUseCase(this._repository);

  @override
  Future<DataState<List<ArticleEntity>>> call({void params}) {
    return _repository.getSavedArticles();
  }
}
