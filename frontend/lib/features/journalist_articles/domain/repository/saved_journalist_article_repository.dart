import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';

/// Articles of the journalists that the signed-in journalist saved to read later, kept in their account.
abstract class SavedJournalistArticleRepository {
  /// Saved articles, the last saved first.
  Future<DataState<List<JournalistArticleEntity>>> getSavedArticles();

  Future<DataState<bool>> isArticleSaved(String articleId);

  Future<DataState<void>> saveArticle(String articleId);

  Future<DataState<void>> removeSavedArticle(String articleId);
}
