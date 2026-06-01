import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/features/search/domain/repository/search_repository.dart';

class SearchCreatorsUseCase
    implements UseCase<DataState<List<UserEntity>>, String> {
  final SearchRepository _repository;

  SearchCreatorsUseCase(this._repository);

  @override
  Future<DataState<List<UserEntity>>> call(String query) {
    return _repository.searchCreators(query);
  }
}
