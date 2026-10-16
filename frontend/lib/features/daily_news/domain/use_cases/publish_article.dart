import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/published_article_repository.dart';

class PublishArticleParams {
  final ArticleDraftEntity draft;

  const PublishArticleParams(this.draft);
}

/// Publishes a draft that follows the business rules of [ArticleDraftEntity];
/// an invalid draft fails with its validation errors without being sent.
class PublishArticleUseCase implements UseCase<DataState<void>, PublishArticleParams> {
  final PublishedArticleRepository _publishedArticleRepository;

  PublishArticleUseCase(this._publishedArticleRepository);

  @override
  Future<DataState<void>> call({PublishArticleParams? params}) async {
    final draft = params!.draft;
    if (!draft.isReadyToPublish) {
      return DataFailed(ArticleDraftValidationException(draft.validationErrors));
    }
    return _publishedArticleRepository.publishArticle(draft);
  }
}
