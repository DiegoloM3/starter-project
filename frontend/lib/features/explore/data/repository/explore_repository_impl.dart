import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/data/models/article_model.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/explore/data/data_sources/explore_remote_data_source.dart';
import 'package:tortutip/features/explore/domain/repository/explore_repository.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDataSource _dataSource;

  ExploreRepositoryImpl(this._dataSource);

  @override
  Future<DataState<List<ArticleEntity>>> getArticlesByCategory(
    String categoryId,
    int page,
    int pageSize,
  ) async {
    try {
      final rawList =
          await _dataSource.getArticlesByCategory(categoryId, page, pageSize);

      final models =
          rawList.map((data) => ArticleModel.fromRawData(data)).toList();

      models.sort((a, b) =>
          (b.publishedAt ?? DateTime(0)).compareTo(a.publishedAt ?? DateTime(0)));

      final skipCount = page * pageSize;
      if (skipCount >= models.length) return const DataSuccess([]);
      final end = (skipCount + pageSize).clamp(0, models.length);
      final paged = models.sublist(skipCount, end);

      return DataSuccess(List<ArticleEntity>.from(paged));
    } on Exception catch (e) {
      return DataFailed(e);
    } catch (e) {
      return DataFailed(Exception(e.toString()));
    }
  }
}
