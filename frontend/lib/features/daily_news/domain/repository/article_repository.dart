import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/paginated_result.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/article_params.dart';

abstract interface class ArticleRepository {
  Future<DataState<PaginatedResult<ArticleEntity>>> getNewsArticles({
    required ArticleParams params,
  });
}
