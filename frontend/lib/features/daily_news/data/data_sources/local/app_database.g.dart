// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ArticleDao? _articleDAOInstance;

  SearchHistoryDao? _searchHistoryDAOInstance;

  CachedArticleDao? _cachedArticleDAOInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 5,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `article` (`id` INTEGER, `author` TEXT, `title` TEXT, `description` TEXT, `url` TEXT, `urlToImage` TEXT, `publishedAt` TEXT, `content` TEXT, `sourceName` TEXT, `savedBy` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `search_history` (`text` TEXT NOT NULL, `searchedAt` INTEGER NOT NULL, PRIMARY KEY (`text`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `cached_article` (`category` TEXT NOT NULL, `position` INTEGER NOT NULL, `savedAt` INTEGER NOT NULL, `id` INTEGER, `author` TEXT, `title` TEXT, `description` TEXT, `url` TEXT, `urlToImage` TEXT, `publishedAt` TEXT, `content` TEXT, `sourceName` TEXT, PRIMARY KEY (`category`, `position`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ArticleDao get articleDAO {
    return _articleDAOInstance ??= _$ArticleDao(database, changeListener);
  }

  @override
  SearchHistoryDao get searchHistoryDAO {
    return _searchHistoryDAOInstance ??=
        _$SearchHistoryDao(database, changeListener);
  }

  @override
  CachedArticleDao get cachedArticleDAO {
    return _cachedArticleDAOInstance ??=
        _$CachedArticleDao(database, changeListener);
  }
}

class _$ArticleDao extends ArticleDao {
  _$ArticleDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _articleModelInsertionAdapter = InsertionAdapter(
            database,
            'article',
            (ArticleModel item) => <String, Object?>{
                  'id': item.id,
                  'author': item.author,
                  'title': item.title,
                  'description': item.description,
                  'url': item.url,
                  'urlToImage': item.urlToImage,
                  'publishedAt': item.publishedAt,
                  'content': item.content,
                  'sourceName': item.sourceName,
                  'savedBy': item.savedBy
                }),
        _articleModelDeletionAdapter = DeletionAdapter(
            database,
            'article',
            ['id'],
            (ArticleModel item) => <String, Object?>{
                  'id': item.id,
                  'author': item.author,
                  'title': item.title,
                  'description': item.description,
                  'url': item.url,
                  'urlToImage': item.urlToImage,
                  'publishedAt': item.publishedAt,
                  'content': item.content,
                  'sourceName': item.sourceName,
                  'savedBy': item.savedBy
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ArticleModel> _articleModelInsertionAdapter;

  final DeletionAdapter<ArticleModel> _articleModelDeletionAdapter;

  @override
  Future<List<ArticleModel>> getArticles(String savedBy) async {
    return _queryAdapter.queryList(
        'SELECT * FROM article WHERE savedBy = ?1',
        mapper: (Map<String, Object?> row) => ArticleModel(
            id: row['id'] as int?,
            author: row['author'] as String?,
            title: row['title'] as String?,
            description: row['description'] as String?,
            url: row['url'] as String?,
            urlToImage: row['urlToImage'] as String?,
            publishedAt: row['publishedAt'] as String?,
            content: row['content'] as String?,
            sourceName: row['sourceName'] as String?,
            savedBy: row['savedBy'] as String?),
        arguments: [savedBy]);
  }

  @override
  Future<void> insertArticle(ArticleModel article) async {
    await _articleModelInsertionAdapter.insert(
        article, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteArticle(ArticleModel articleModel) async {
    await _articleModelDeletionAdapter.delete(articleModel);
  }
}

class _$SearchHistoryDao extends SearchHistoryDao {
  _$SearchHistoryDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _searchHistoryModelInsertionAdapter = InsertionAdapter(
            database,
            'search_history',
            (SearchHistoryModel item) => <String, Object?>{
                  'text': item.text,
                  'searchedAt': item.searchedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<SearchHistoryModel>
      _searchHistoryModelInsertionAdapter;

  @override
  Future<List<SearchHistoryModel>> getRecentSearches() async {
    return _queryAdapter.queryList(
        'SELECT * FROM search_history ORDER BY searchedAt DESC LIMIT 10',
        mapper: (Map<String, Object?> row) => SearchHistoryModel(
            text: row['text'] as String, searchedAt: row['searchedAt'] as int));
  }

  @override
  Future<void> insertSearch(SearchHistoryModel search) async {
    await _searchHistoryModelInsertionAdapter.insert(
        search, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteSearch(String text) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM search_history WHERE text = ?1',
        arguments: [text]);
  }

  @override
  Future<void> deleteOlderSearches() async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM search_history WHERE text NOT IN (SELECT text FROM search_history ORDER BY searchedAt DESC LIMIT 10)');
  }
}

class _$CachedArticleDao extends CachedArticleDao {
  _$CachedArticleDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _cachedArticleModelInsertionAdapter = InsertionAdapter(
            database,
            'cached_article',
            (CachedArticleModel item) => <String, Object?>{
                  'category': item.category,
                  'position': item.position,
                  'savedAt': item.savedAt,
                  'id': item.id,
                  'author': item.author,
                  'title': item.title,
                  'description': item.description,
                  'url': item.url,
                  'urlToImage': item.urlToImage,
                  'publishedAt': item.publishedAt,
                  'content': item.content,
                  'sourceName': item.sourceName
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CachedArticleModel>
      _cachedArticleModelInsertionAdapter;

  @override
  Future<List<CachedArticleModel>> getCachedArticles(String category) async {
    return _queryAdapter.queryList(
        'SELECT * FROM cached_article WHERE category = ?1 ORDER BY position',
        mapper: (Map<String, Object?> row) => CachedArticleModel(
            category: row['category'] as String,
            position: row['position'] as int,
            savedAt: row['savedAt'] as int,
            author: row['author'] as String?,
            title: row['title'] as String?,
            description: row['description'] as String?,
            url: row['url'] as String?,
            urlToImage: row['urlToImage'] as String?,
            publishedAt: row['publishedAt'] as String?,
            content: row['content'] as String?,
            sourceName: row['sourceName'] as String?),
        arguments: [category]);
  }

  @override
  Future<void> deleteCategory(String category) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM cached_article WHERE category = ?1',
        arguments: [category]);
  }

  @override
  Future<void> insertArticles(List<CachedArticleModel> articles) async {
    await _cachedArticleModelInsertionAdapter.insertList(
        articles, OnConflictStrategy.replace);
  }
}
