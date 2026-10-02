import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/saved_journalist_article_repository.dart';

class GetSavedJournalistArticlesUseCase implements UseCase<DataState<List<JournalistArticleEntity>>, void> {
  final SavedJournalistArticleRepository _savedArticleRepository;

  GetSavedJournalistArticlesUseCase(this._savedArticleRepository);

  @override
  Future<DataState<List<JournalistArticleEntity>>> call({void params}) => _savedArticleRepository.getSavedArticles();
}
