import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

class NewsApiCacheService {
  final AppDatabase _appDatabase;

  NewsApiCacheService(this._appDatabase);

  static const _tableName = 'cached_article';

  Future<void> ensureTableCreated() async {
    await _appDatabase.database.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        author TEXT,
        title TEXT,
        description TEXT,
        url TEXT,
        urlToImage TEXT,
        publishedAt TEXT,
        content TEXT
      )
    ''');
  }

  Future<void> cacheArticles(List<ArticleModel> articles) async {
    final db = _appDatabase.database;
    await db.execute('DELETE FROM $_tableName');
    final batch = db.batch();
    for (final article in articles) {
      batch.insert(_tableName, {
        'author': article.author,
        'title': article.title,
        'description': article.description,
        'url': article.url,
        'urlToImage': article.urlToImage,
        'publishedAt': article.publishedAt,
        'content': article.content,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<ArticleModel>> getCachedArticles() async {
    final rows = await _appDatabase.database.query(_tableName);
    return rows
        .map((row) => ArticleModel(
              id: row['id'] as int?,
              author: row['author'] as String?,
              title: row['title'] as String?,
              description: row['description'] as String?,
              url: row['url'] as String?,
              urlToImage: row['urlToImage'] as String?,
              publishedAt: row['publishedAt'] as String?,
              content: row['content'] as String?,
            ))
        .toList();
  }
}
