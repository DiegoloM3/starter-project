import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/shared/user/domain/repository/user_repository.dart';

class GetUserCategoryIdsParams extends Equatable {
  final String userId;

  const GetUserCategoryIdsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetUserCategoryIdsUseCase
    implements UseCase<DataState<List<String>>, GetUserCategoryIdsParams> {
  final UserRepository _repository;

  GetUserCategoryIdsUseCase(this._repository);

  @override
  Future<DataState<List<String>>> call(GetUserCategoryIdsParams params) {
    return _repository.getUserCategoryIds(params.userId);
  }
}
