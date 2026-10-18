import '../../../../core/resources/data_state.dart';
import '../../domain/entities/article.dart';
import '../../domain/repository/saved_articles_repository.dart';
import '../data_sources/remote/article_remote_data_source.dart';
import '../data_sources/remote/saved_articles_remote_data_source.dart';

class SavedArticlesRepositoryImpl implements SavedArticlesRepository {
  final SavedArticlesRemoteDataSource _savedArticlesDataSource;
  final ArticleRemoteDataSource _articleDataSource;

  SavedArticlesRepositoryImpl(this._savedArticlesDataSource, this._articleDataSource);

  /// Keeps the order in which they were saved. Articles deleted by their author are skipped.
  @override
  Future<DataState<List<ArticleEntity>>> getSavedArticles() {
    return runAsDataState(() async {
      final savedIds = await _savedArticlesDataSource.getSavedArticleIds();
      final articles = await _articleDataSource.getArticlesByIds(savedIds);
      final articlesById = {for (final article in articles) article.id: article.toEntity()};
      return savedIds.map((id) => articlesById[id]).whereType<ArticleEntity>().toList();
    });
  }

  @override
  Future<DataState<void>> saveArticle(String articleId) {
    return runAsDataState(() => _savedArticlesDataSource.saveArticle(articleId));
  }

  @override
  Future<DataState<void>> removeSavedArticle(String articleId) {
    return runAsDataState(() => _savedArticlesDataSource.removeSavedArticle(articleId));
  }
}
