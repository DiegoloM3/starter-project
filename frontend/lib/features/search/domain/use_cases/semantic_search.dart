import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/search/domain/params/semantic_search_params.dart';
import 'package:news_app_clean_architecture/features/search/domain/repository/search_repository.dart';

class SemanticSearchUseCase
    implements UseCase<DataState<List<String>>, SemanticSearchParams> {
  final SearchRepository _repository;

  SemanticSearchUseCase(this._repository);

  @override
  Future<DataState<List<String>>> call({SemanticSearchParams? params}) {
    assert(params != null, 'SemanticSearchParams must not be null');
    return _repository.searchArticles(params!);
  }
}
