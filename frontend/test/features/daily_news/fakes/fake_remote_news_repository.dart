import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/remote_news_repository.dart';

class FakeRemoteNewsRepository implements RemoteNewsRepository {
  DataState<List<ArticleEntity>>? getResult;

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles({int page = 1}) async =>
      getResult ?? const DataSuccess([]);
}
