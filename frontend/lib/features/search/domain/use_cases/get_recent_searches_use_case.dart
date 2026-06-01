import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/search/domain/repository/search_repository.dart';

class GetRecentSearchesUseCase
    implements UseCase<DataState<List<String>>, NoParams> {
  final SearchRepository _repository;

  GetRecentSearchesUseCase(this._repository);

  @override
  Future<DataState<List<String>>> call(NoParams params) {
    return _repository.getRecentSearches();
  }
}
