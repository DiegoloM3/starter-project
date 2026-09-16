import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/saved_article_repository.dart';

/// Removes a bookmark by article id.
class RemoveSavedArticleUseCase implements UseCase<DataState<void>, String> {
  final SavedArticleRepository _savedArticleRepository;

  const RemoveSavedArticleUseCase(this._savedArticleRepository);

  @override
  Future<DataState<void>> call(String params) {
    return _savedArticleRepository.removeArticle(params);
  }
}
