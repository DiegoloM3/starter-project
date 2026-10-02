import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/saved_journalist_article_repository.dart';

/// [call] receives the ID of the article.
class SaveJournalistArticleUseCase implements UseCase<DataState<void>, String> {
  final SavedJournalistArticleRepository _savedArticleRepository;

  SaveJournalistArticleUseCase(this._savedArticleRepository);

  @override
  Future<DataState<void>> call({String? params}) => _savedArticleRepository.saveArticle(params!);
}
