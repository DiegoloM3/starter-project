import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/search/domain/params/search_articles_params.dart';
import 'package:tortutip/features/search/domain/repository/search_repository.dart';

class SearchArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, SearchArticlesParams> {
  final SearchRepository _repository;

  SearchArticlesUseCase(this._repository);

  @override
  Future<DataState<List<ArticleEntity>>> call(SearchArticlesParams params) {
    return _repository.searchArticles(params.query);
  }
}
