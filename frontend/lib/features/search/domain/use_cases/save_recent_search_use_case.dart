import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/search/domain/repository/search_repository.dart';

class SaveRecentSearchUseCase implements UseCase<DataState<bool>, String> {
  final SearchRepository _repository;

  SaveRecentSearchUseCase(this._repository);

  @override
  Future<DataState<bool>> call(String params) {
    return _repository.saveRecentSearch(params);
  }
}
