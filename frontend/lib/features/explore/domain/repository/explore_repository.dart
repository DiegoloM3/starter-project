import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';

abstract class ExploreRepository {
  Future<DataState<List<ArticleEntity>>> getArticlesByCategory(
    String categoryId,
    int page,
    int pageSize,
  );
}
