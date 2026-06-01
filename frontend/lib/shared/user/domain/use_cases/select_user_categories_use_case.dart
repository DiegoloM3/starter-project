import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/shared/user/domain/repository/user_repository.dart';

class SelectUserCategoriesParams extends Equatable {
  final String userId;
  final List<String> categoryIds;

  const SelectUserCategoriesParams({
    required this.userId,
    required this.categoryIds,
  });

  @override
  List<Object?> get props => [userId, categoryIds];
}

class SelectUserCategoriesUseCase
    implements UseCase<DataState<bool>, SelectUserCategoriesParams> {
  final UserRepository _repository;
  SelectUserCategoriesUseCase(this._repository);

  @override
  Future<DataState<bool>> call(SelectUserCategoriesParams params) {
    return _repository.selectUserCategories(params.userId, params.categoryIds);
  }
}
