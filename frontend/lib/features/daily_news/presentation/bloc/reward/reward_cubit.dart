import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/reward_api_service.dart';
import 'reward_state.dart';

class RewardCubit extends Cubit<RewardState> {
  final RewardApiService _rewardApiService;

  RewardCubit(this._rewardApiService) : super(RewardInitial());

  Future<void> claimReward(String userId, String articleUrl, double readTime) async {
    if (articleUrl.isEmpty) return;

    emit(RewardClaiming());

    try {
      final result = await _rewardApiService.claimReward(userId, articleUrl, readTime);
      
      if (result['status'] == 'success') {
        final amount = (result['reward'] as num).toDouble();
        emit(RewardClaimSuccess(amount, result['message'] ?? 'Recompensa obtenida'));
      } else {
        emit(RewardClaimError(result['message'] ?? 'Fallo al reclamar recompensa'));
      }
    } catch (e) {
      // Detailed error if possible
      String errorMessage = 'Error de conexión';
      if (e is DioException && e.response?.data != null) {
         errorMessage = e.response?.data['detail'] ?? errorMessage;
      }
      emit(RewardClaimError(errorMessage));
    }
  }

}
