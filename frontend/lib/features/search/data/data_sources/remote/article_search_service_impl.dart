import 'package:cloud_functions/cloud_functions.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/search/data/data_sources/remote/article_search_service.dart';

class ArticleSearchServiceImpl implements ArticleSearchService {
  final FirebaseFunctions _functions;

  ArticleSearchServiceImpl(this._functions);

  @override
  Future<List<String>> searchArticles(String query, {int limit = 10}) async {
    try {
      final callable = _functions.httpsCallable('searchArticles');
      final result = await callable.call({'query': query, 'limit': limit});
      final data = result.data as Map<Object?, Object?>;
      final results = (data['results'] as List<Object?>?) ?? const [];
      return results
          .whereType<Map<Object?, Object?>>()
          .map((entry) => entry['articleId'] as String)
          .toList();
    } on FirebaseFunctionsException catch (e) {
      throw _mapException(e);
    }
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
          message: e.message ?? 'Too many search queries',
          code: 'rate-limit',
          cause: e,
        );
      case 'invalid-argument':
        return ValidationException(
          message: e.message ?? 'Invalid search arguments',
          code: e.code,
          cause: e,
        );
      default:
        return NetworkException(
          message: e.message ?? 'Search failed',
          code: e.code,
          cause: e,
        );
    }
  }
}
