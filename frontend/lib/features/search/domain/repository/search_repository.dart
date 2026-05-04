import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/search/domain/params/semantic_search_params.dart';

abstract class SearchRepository {
  Future<DataState<List<String>>> searchArticles(SemanticSearchParams params);
}
