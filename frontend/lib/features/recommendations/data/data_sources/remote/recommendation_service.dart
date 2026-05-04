import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class RecommendationService {
  Future<List<ArticleEntity>> recommendForUser({int limit = 20});
}
