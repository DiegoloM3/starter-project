import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/article_narration.dart';
import '../entities/article_narration_progress.dart';
import '../entities/published_article.dart';
import '../repository/article_narrator_repository.dart';

/// Reads an article aloud: title, byline and content, in the article's language.
/// Emits which sentence is being read, and ends when the reading ends or is stopped.
class ReadArticleAloudUseCase
    implements StreamUseCase<DataState<ArticleNarrationProgressEntity>, PublishedArticleEntity> {
  final ArticleNarratorRepository _articleNarratorRepository;

  ReadArticleAloudUseCase(this._articleNarratorRepository);

  @override
  Stream<DataState<ArticleNarrationProgressEntity>> call({PublishedArticleEntity? params}) {
    if (params == null) return const Stream.empty();
    return _articleNarratorRepository.read(ArticleNarrationEntity.of(params));
  }
}
