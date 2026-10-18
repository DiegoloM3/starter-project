import '../../../../core/resources/data_state.dart';
import '../../domain/entities/article.dart';
import '../../domain/repository/reading_history_repository.dart';
import '../data_sources/remote/article_remote_data_source.dart';
import '../data_sources/remote/reading_history_remote_data_source.dart';

class ReadingHistoryRepositoryImpl implements ReadingHistoryRepository {
  final ReadingHistoryRemoteDataSource _historyDataSource;
  final ArticleRemoteDataSource _articleDataSource;

  ReadingHistoryRepositoryImpl(this._historyDataSource, this._articleDataSource);

  @override
  Future<DataState<void>> recordView(String articleId) {
    return runAsDataState(() => _historyDataSource.recordView(articleId));
  }

  @override
  Future<DataState<void>> deleteViewsBeyond(int count) {
    return runAsDataState(() => _historyDataSource.deleteViewsBeyond(count));
  }

  /// Keeps the order in which they were viewed. Articles deleted by their author are skipped.
  @override
  Future<DataState<List<ArticleEntity>>> getRecentlyViewed(int count) {
    return runAsDataState(() async {
      final viewedIds = await _historyDataSource.getRecentArticleIds(count);
      final articles = await _articleDataSource.getArticlesByIds(viewedIds);
      final articlesById = {for (final article in articles) article.id: article.toEntity()};
      return viewedIds.map((id) => articlesById[id]).whereType<ArticleEntity>().toList();
    });
  }
}
