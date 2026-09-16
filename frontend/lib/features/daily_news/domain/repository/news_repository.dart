import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';

/// Articles published by the external news provider.
abstract interface class NewsRepository {
  Future<DataState<List<ArticleEntity>>> getTopHeadlines(NewsQuery query);

  Future<DataState<List<ArticleEntity>>> searchArticles(String query);
}
