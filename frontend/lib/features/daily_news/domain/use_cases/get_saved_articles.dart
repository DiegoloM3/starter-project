import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/saved_article_repository.dart';

class GetSavedArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, NoParams> {
  final SavedArticleRepository _savedArticleRepository;

  const GetSavedArticlesUseCase(this._savedArticleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call(NoParams params) {
    return _savedArticleRepository.getSavedArticles();
  }
}
