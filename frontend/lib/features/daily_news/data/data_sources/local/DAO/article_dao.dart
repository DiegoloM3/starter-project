import 'package:floor/floor.dart';

import '../saved_article_record.dart';

@dao
abstract class ArticleDao {

  @Insert()
  Future<void> insertArticle(SavedArticleRecord article);

  @delete
  Future<void> deleteArticle(SavedArticleRecord article);

  @Query('SELECT * FROM article')
  Future<List<SavedArticleRecord>> getArticles();

  /// A NewsAPI article is identified by its URL: it has no ID until it is saved here.
  @Query('SELECT * FROM article WHERE url = :url')
  Future<SavedArticleRecord?> findArticleByUrl(String url);

  @Query('DELETE FROM article WHERE url = :url')
  Future<void> deleteArticleByUrl(String url);
}
