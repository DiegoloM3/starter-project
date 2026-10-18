import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/resources/data_state.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/get_trending_topics.dart';
import 'trends_state.dart';

class TrendsCubit extends Cubit<TrendsState> {
  final GetTrendingTopicsUseCase _getTrendingTopicsUseCase;

  TrendsCubit(this._getTrendingTopicsUseCase) : super(const TrendsState());

  /// The current trends stay visible while loading and if it fails.
  Future<void> load() async {
    emit(TrendsState(status: TrendsStatus.loading, trends: state.trends));
    final result = await _getTrendingTopicsUseCase(const NoParams());
    if (result is DataSuccess) {
      emit(TrendsState(status: TrendsStatus.success, trends: result.data!));
    } else {
      emit(TrendsState(status: TrendsStatus.failure, trends: state.trends));
    }
  }
}
