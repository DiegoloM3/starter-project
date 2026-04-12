// GENERATED-LIKE CODE — written manually because retrofit_generator 8.1.0
// fails to compile on Dart 3.9.0. This file mirrors the structure that
// `dart run build_runner build` would produce for floor 1.4.2.
//
// It can be regenerated safely once retrofit_generator is upgraded to a
// version compatible with Dart 3.9+ (tracked in README_best.md).

// ignore_for_file: library_private_types_in_public_api, no_leading_underscores_for_local_identifiers

part of 'articles_local_database.dart';

class $FloorArticlesLocalDatabase {
  /// Creates a database builder for a persistent database.
  static _$ArticlesLocalDatabaseBuilder databaseBuilder(String name) =>
      _$ArticlesLocalDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  static _$ArticlesLocalDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$ArticlesLocalDatabaseBuilder(null);
}

class _$ArticlesLocalDatabaseBuilder {
  _$ArticlesLocalDatabaseBuilder(this.name);

  final String? name;
  final List<Migration> _migrations = [];
  Callback? _callback;

  _$ArticlesLocalDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  _$ArticlesLocalDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  Future<ArticlesLocalDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$ArticlesLocalDatabase();
    database.database = await database.open(path, _migrations, _callback);
    return database;
  }
}

class _$ArticlesLocalDatabase extends ArticlesLocalDatabase {
  _$ArticlesLocalDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ArticleUploadDao? _articleUploadDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
          database,
          startVersion,
          endVersion,
          migrations,
        );
        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `article_upload` ('
          '`id` TEXT NOT NULL, '
          '`title` TEXT NOT NULL, '
          '`description` TEXT NOT NULL, '
          '`content` TEXT NOT NULL, '
          '`author` TEXT NOT NULL, '
          '`authorUid` TEXT NOT NULL, '
          '`thumbnailURL` TEXT NOT NULL, '
          '`sourceName` TEXT, '
          '`publishedAt` INTEGER NOT NULL, '
          '`createdAt` INTEGER NOT NULL, '
          '`updatedAt` INTEGER NOT NULL, '
          '`deletedAt` INTEGER, '
          'PRIMARY KEY (`id`))',
        );
        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ArticleUploadDao get articleUploadDao {
    return _articleUploadDaoInstance ??=
        _$ArticleUploadDao(database, changeListener);
  }
}

class _$ArticleUploadDao extends ArticleUploadDao {
  _$ArticleUploadDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _insertionAdapter = InsertionAdapter(
          database,
          'article_upload',
          (ArticleUploadFloorEntity item) => <String, Object?>{
            'id': item.id,
            'title': item.title,
            'description': item.description,
            'content': item.content,
            'author': item.author,
            'authorUid': item.authorUid,
            'thumbnailURL': item.thumbnailURL,
            'sourceName': item.sourceName,
            'publishedAt': item.publishedAt,
            'createdAt': item.createdAt,
            'updatedAt': item.updatedAt,
            'deletedAt': item.deletedAt,
          },
        );

  final sqflite.DatabaseExecutor database;
  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;
  final InsertionAdapter<ArticleUploadFloorEntity> _insertionAdapter;

  @override
  Future<List<ArticleUploadFloorEntity>> getAllLive() async {
    return _queryAdapter.queryList(
      'SELECT * FROM article_upload WHERE deletedAt IS NULL ORDER BY publishedAt DESC',
      mapper: (Map<String, Object?> row) => ArticleUploadFloorEntity(
        id: row['id'] as String,
        title: row['title'] as String,
        description: row['description'] as String,
        content: row['content'] as String,
        author: row['author'] as String,
        authorUid: row['authorUid'] as String,
        thumbnailURL: row['thumbnailURL'] as String,
        sourceName: row['sourceName'] as String?,
        publishedAt: row['publishedAt'] as int,
        createdAt: row['createdAt'] as int,
        updatedAt: row['updatedAt'] as int,
        deletedAt: row['deletedAt'] as int?,
      ),
    );
  }

  @override
  Future<List<ArticleUploadFloorEntity>> getAll() async {
    return _queryAdapter.queryList(
      'SELECT * FROM article_upload ORDER BY publishedAt DESC',
      mapper: (Map<String, Object?> row) => ArticleUploadFloorEntity(
        id: row['id'] as String,
        title: row['title'] as String,
        description: row['description'] as String,
        content: row['content'] as String,
        author: row['author'] as String,
        authorUid: row['authorUid'] as String,
        thumbnailURL: row['thumbnailURL'] as String,
        sourceName: row['sourceName'] as String?,
        publishedAt: row['publishedAt'] as int,
        createdAt: row['createdAt'] as int,
        updatedAt: row['updatedAt'] as int,
        deletedAt: row['deletedAt'] as int?,
      ),
    );
  }

  @override
  Future<void> removeById(String id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM article_upload WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> clearAll() async {
    await _queryAdapter.queryNoReturn('DELETE FROM article_upload');
  }

  @override
  Future<void> upsertArticle(ArticleUploadFloorEntity entity) async {
    await _insertionAdapter.insert(entity, OnConflictStrategy.replace);
  }

  @override
  Future<void> upsertAll(List<ArticleUploadFloorEntity> entities) async {
    await _insertionAdapter.insertList(entities, OnConflictStrategy.replace);
  }
}
