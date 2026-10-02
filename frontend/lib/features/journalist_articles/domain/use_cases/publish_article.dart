import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/journalist_article_repository.dart';

class PublishArticleUseCase
    implements UseCase<DataState<JournalistArticleEntity>, ArticleDraftEntity> {
  final JournalistArticleRepository _journalistArticleRepository;

  PublishArticleUseCase(this._journalistArticleRepository);

  @override
  Future<DataState<JournalistArticleEntity>> call({
    ArticleDraftEntity? params,
  }) async {
    final draft = params!;
    if (!draft.isValid) {
      return DataFailed(InvalidArticleDraftException(draft));
    }
    return _journalistArticleRepository.publishArticle(draft);
  }
}
