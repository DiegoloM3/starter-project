import '../../../../core/resources/data_state.dart';
import '../entities/article.dart';

/// Saved articles of the signed in user.
abstract class SavedArticlesRepository {
  Future<DataState<List<ArticleEntity>>> getSavedArticles();

  Future<DataState<void>> saveArticle(String articleId);

  Future<DataState<void>> removeSavedArticle(String articleId);
}
