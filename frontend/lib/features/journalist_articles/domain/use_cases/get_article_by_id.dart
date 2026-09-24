import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/journalist_article.dart';
import '../params/get_article_by_id_params.dart';
import '../repository/journalist_article_repository.dart';

/// Reads a single article, used by the detail and the edit screens.
class GetArticleByIdUseCase
    implements
        UseCase<DataState<JournalistArticleEntity>, GetArticleByIdParams> {
  final JournalistArticleRepository _articleRepository;

  const GetArticleByIdUseCase(this._articleRepository);

  @override
  Future<DataState<JournalistArticleEntity>> call(
    GetArticleByIdParams params,
  ) {
    return _articleRepository.getArticleById(params.articleId);
  }
}
