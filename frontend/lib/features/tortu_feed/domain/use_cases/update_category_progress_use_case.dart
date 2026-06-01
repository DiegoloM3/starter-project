import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/tortu_feed/domain/repository/tortu_feed_repository.dart';

class UpdateCategoryProgressUseCase
    implements UseCase<DataState<double>, UpdateCategoryProgressParams> {
  final TortuFeedRepository _repository;

  UpdateCategoryProgressUseCase(this._repository);

  @override
  Future<DataState<double>> call(UpdateCategoryProgressParams params) {
    return _repository.updateCategoryProgress(params);
  }
}
