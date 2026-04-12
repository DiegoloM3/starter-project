import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class RemoteNewsRepository {
  Future<DataState<List<ArticleEntity>>> getNewsArticles({int page = 1});
}
