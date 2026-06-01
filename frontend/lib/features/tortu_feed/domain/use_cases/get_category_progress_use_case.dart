import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/tortu_feed/domain/repository/tortu_feed_repository.dart';

class GetCategoryProgressUseCase
    implements UseCase<DataState<double>, GetCategoryProgressParams> {
  final TortuFeedRepository _repository;

  GetCategoryProgressUseCase(this._repository);

  @override
  Future<DataState<double>> call(GetCategoryProgressParams params) {
    return _repository.getCategoryProgress(params);
  }
}
