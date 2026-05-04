import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/recommendations/data/data_sources/remote/recommendation_service.dart';
import 'package:news_app_clean_architecture/features/recommendations/domain/repository/recommendation_repository.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationService _service;

  RecommendationRepositoryImpl(this._service);

  @override
  Future<DataState<List<ArticleEntity>>> recommendForUser({int limit = 20}) async {
    try {
      final articles = await _service.recommendForUser(limit: limit);
      return DataSuccess(articles);
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e, st) {
      return DataFailed(
        UnknownException(message: e.toString(), cause: e, stackTrace: st),
      );
    }
  }
}
