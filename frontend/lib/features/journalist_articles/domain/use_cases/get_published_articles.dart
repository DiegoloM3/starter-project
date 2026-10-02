import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/journalist_article_repository.dart';

class GetPublishedArticlesUseCase
    implements UseCase<DataState<List<JournalistArticleEntity>>, void> {
  final JournalistArticleRepository _journalistArticleRepository;

  GetPublishedArticlesUseCase(this._journalistArticleRepository);

  @override
  Future<DataState<List<JournalistArticleEntity>>> call({void params}) {
    return _journalistArticleRepository.getPublishedArticles();
  }
}
