import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../params/increment_article_view_count_params.dart';
import '../repository/journalist_article_repository.dart';

/// Records that a reader opened a published article.
class IncrementArticleViewCountUseCase
    implements UseCase<DataState<void>, IncrementArticleViewCountParams> {
  final JournalistArticleRepository _articleRepository;

  const IncrementArticleViewCountUseCase(this._articleRepository);

  @override
  Future<DataState<void>> call(IncrementArticleViewCountParams params) {
    return _articleRepository.incrementViewCount(params.articleId);
  }
}
