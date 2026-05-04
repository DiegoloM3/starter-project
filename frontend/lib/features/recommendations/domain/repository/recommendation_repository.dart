import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class RecommendationRepository {
  Future<DataState<List<ArticleEntity>>> recommendForUser({int limit = 20});
}
