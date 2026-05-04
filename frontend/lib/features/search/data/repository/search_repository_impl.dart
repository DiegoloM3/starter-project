import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/search/data/data_sources/remote/article_search_service.dart';
import 'package:news_app_clean_architecture/features/search/domain/params/semantic_search_params.dart';
import 'package:news_app_clean_architecture/features/search/domain/repository/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final ArticleSearchService _service;

  SearchRepositoryImpl(this._service);

  @override
  Future<DataState<List<String>>> searchArticles(
      SemanticSearchParams params) async {
    try {
      final ids =
          await _service.searchArticles(params.query, limit: params.limit);
      return DataSuccess(ids);
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e, st) {
      return DataFailed(
          UnknownException(message: e.toString(), cause: e, stackTrace: st));
    }
  }
}
