import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/tortu_feed/domain/repository/tortu_feed_repository.dart';

class CheckTodayTipUseCase implements UseCase<DataState<bool>, CheckTodayTipParams> {
  final TortuFeedRepository _repository;

  CheckTodayTipUseCase(this._repository);

  @override
  Future<DataState<bool>> call(CheckTodayTipParams params) {
    return _repository.checkTodayTip(params);
  }
}
