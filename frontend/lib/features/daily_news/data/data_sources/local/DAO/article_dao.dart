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
}
