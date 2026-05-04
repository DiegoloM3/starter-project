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

  DraftDao? _draftDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 2,
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
            'CREATE TABLE IF NOT EXISTS `article` (`id` INTEGER, `author` TEXT, `title` TEXT, `description` TEXT, `url` TEXT, `urlToImage` TEXT, `publishedAt` TEXT, `content` TEXT, PRIMARY KEY (`id`))');

        await database.execute(
            'CREATE TABLE IF NOT EXISTS `draft_articles` (`draftId` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `description` TEXT NOT NULL, `content` TEXT NOT NULL, `localImagePath` TEXT, `categoryRaw` TEXT, `tagsRaw` TEXT NOT NULL, `language` TEXT NOT NULL, `locationLat` REAL, `locationLng` REAL, `locationPlaceName` TEXT, `lastSavedAtMillis` INTEGER NOT NULL)');

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
  DraftDao get draftDao {
    return _draftDaoInstance ??= _$DraftDao(database, changeListener);
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
                  'content': item.content
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
                  'content': item.content
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ArticleModel> _articleModelInsertionAdapter;

  final DeletionAdapter<ArticleModel> _articleModelDeletionAdapter;

  @override
  Future<List<ArticleModel>> getArticles() async {
    return _queryAdapter.queryList('SELECT * FROM article',
        mapper: (Map<String, Object?> row) => ArticleModel(
            id: row['id'] as int?,
            author: row['author'] as String?,
            title: row['title'] as String?,
            description: row['description'] as String?,
            url: row['url'] as String?,
            urlToImage: row['urlToImage'] as String?,
            publishedAt: row['publishedAt'] as String?,
            content: row['content'] as String?));
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

class _$DraftDao extends DraftDao {
  _$DraftDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _draftArticleModelInsertionAdapter = InsertionAdapter(
            database,
            'draft_articles',
            (DraftArticleModel item) => <String, Object?>{
                  'draftId': item.draftId,
                  'title': item.title,
                  'description': item.description,
                  'content': item.content,
                  'localImagePath': item.localImagePath,
                  'categoryRaw': item.categoryRaw,
                  'tagsRaw': item.tagsRaw,
                  'language': item.language,
                  'locationLat': item.locationLat,
                  'locationLng': item.locationLng,
                  'locationPlaceName': item.locationPlaceName,
                  'lastSavedAtMillis': item.lastSavedAtMillis,
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<DraftArticleModel> _draftArticleModelInsertionAdapter;

  DraftArticleModel _draftRowMapper(Map<String, Object?> row) {
    return DraftArticleModel(
      draftId: row['draftId'] as int?,
      title: row['title'] as String,
      description: row['description'] as String,
      content: row['content'] as String,
      localImagePath: row['localImagePath'] as String?,
      categoryRaw: row['categoryRaw'] as String?,
      tagsRaw: row['tagsRaw'] as String,
      language: row['language'] as String,
      locationLat: row['locationLat'] as double?,
      locationLng: row['locationLng'] as double?,
      locationPlaceName: row['locationPlaceName'] as String?,
      lastSavedAtMillis: row['lastSavedAtMillis'] as int,
    );
  }

  @override
  Stream<List<DraftArticleModel>> watchDrafts() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM draft_articles ORDER BY lastSavedAtMillis DESC',
        mapper: _draftRowMapper,
        queryableName: 'draft_articles',
        isView: false);
  }

  @override
  Future<DraftArticleModel?> getDraft(int id) async {
    return _queryAdapter.query(
        'SELECT * FROM draft_articles WHERE draftId = ?1',
        mapper: _draftRowMapper,
        arguments: [id]);
  }

  @override
  Future<int> upsertDraft(DraftArticleModel draft) {
    return _draftArticleModelInsertionAdapter.insertAndReturnId(
        draft, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteDraft(int id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM draft_articles WHERE draftId = ?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteAllDrafts() async {
    await _queryAdapter.queryNoReturn('DELETE FROM draft_articles');
  }
}
