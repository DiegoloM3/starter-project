import 'package:cloud_functions/cloud_functions.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/recommendations/data/data_sources/remote/recommendation_service.dart';

class RecommendationServiceImpl implements RecommendationService {
  final FirebaseFunctions _functions;

  RecommendationServiceImpl(this._functions);

  @override
  Future<List<ArticleEntity>> recommendForUser({int limit = 20}) async {
    try {
      final callable = _functions.httpsCallable('recommendForUser');
      final result = await callable.call({'limit': limit});
      final data = result.data as Map<Object?, Object?>;
      final results = (data['results'] as List<Object?>?) ?? const [];
      return results
          .whereType<Map<Object?, Object?>>()
          .map(_toEntity)
          .toList();
    } on FirebaseFunctionsException catch (e) {
      throw _mapException(e);
    }
  }

  ArticleEntity _toEntity(Map<Object?, Object?> entry) {
    return ArticleEntity(
      author: entry['author'] as String? ?? '',
      title: entry['title'] as String? ?? '',
      description: entry['description'] as String? ?? '',
      url: entry['url'] as String? ?? '',
      urlToImage: entry['urlToImage'] as String? ?? '',
      publishedAt: entry['publishedAt'] as String? ?? '',
      content: entry['content'] as String? ?? '',
    );
  }

  AppException _mapException(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return AuthException(
          message: e.message ?? 'Sign in required',
          code: 'unauthenticated',
          cause: e,
        );
      case 'resource-exhausted':
        return NetworkException(
          message: e.message ?? 'Too many requests',
          code: 'rate-limit',
          cause: e,
        );
      case 'invalid-argument':
        return ValidationException(
          message: e.message ?? 'Invalid request',
          code: e.code,
          cause: e,
        );
      default:
        return NetworkException(
          message: e.message ?? 'Recommendation failed',
          code: e.code,
          cause: e,
        );
    }
  }
}
