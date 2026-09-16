import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/saved_article_repository.dart';

class SaveArticleUseCase implements UseCase<DataState<void>, ArticleEntity> {
  final SavedArticleRepository _savedArticleRepository;

  const SaveArticleUseCase(this._savedArticleRepository);

  @override
  Future<DataState<void>> call(ArticleEntity params) {
    return _savedArticleRepository.saveArticle(params);
  }
}
