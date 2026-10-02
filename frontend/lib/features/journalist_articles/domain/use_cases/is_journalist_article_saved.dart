import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/saved_journalist_article_repository.dart';

/// [call] receives the ID of the article.
class IsJournalistArticleSavedUseCase implements UseCase<DataState<bool>, String> {
  final SavedJournalistArticleRepository _savedArticleRepository;

  IsJournalistArticleSavedUseCase(this._savedArticleRepository);

  @override
  Future<DataState<bool>> call({String? params}) => _savedArticleRepository.isArticleSaved(params!);
}
