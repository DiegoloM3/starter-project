import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/config/api_config.dart';

class RewardApiService {
  final Dio _dio;

  RewardApiService(this._dio);

  Future<Map<String, dynamic>> claimReward(String userId, String articleId, double readTime) async {
    try {
      final response = await _dio.post(
        'rewards/claim',
        data: {
          'userId': userId,
          'articleId': articleId,
          'readTime': readTime,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBalance(String userId) async {
    try {
      final response = await _dio.get('rewards/balance/$userId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
