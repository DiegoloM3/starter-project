import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

abstract class SearchRepository {
  Future<DataState<List<ArticleEntity>>> searchArticles(String query);
  Future<DataState<List<CategoryEntity>>> searchCategories(String query);
  Future<DataState<List<UserEntity>>> searchCreators(String query);
  Future<DataState<List<String>>> getRecentSearches();
  Future<DataState<bool>> saveRecentSearch(String query);
  Future<DataState<bool>> removeRecentSearch(String query);
}
