import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/search/domain/repository/search_repository.dart';

class RemoveRecentSearchUseCase implements UseCase<DataState<bool>, String> {
  final SearchRepository _repository;

  RemoveRecentSearchUseCase(this._repository);

  @override
  Future<DataState<bool>> call(String params) {
    return _repository.removeRecentSearch(params);
  }
}
