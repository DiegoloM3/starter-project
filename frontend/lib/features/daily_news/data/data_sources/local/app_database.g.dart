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
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `article` (`id` TEXT, `title` TEXT, `description` TEXT, `content` TEXT, `authorId` TEXT, `authorName` TEXT, `thumbnailUrl` TEXT, `thumbnailPath` TEXT, `url` TEXT, `publishedAt` TEXT, `createdAt` TEXT, `updatedAt` TEXT, `status` TEXT, `isDeleted` INTEGER, `readingTimeMinutes` INTEGER, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ArticleDao get articleDAO {
    return _articleDAOInstance ??= _$ArticleDao(database, changeListener);
  }
}

class _$ArticleDao extends ArticleDao {
  _$ArticleDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _articleModelInsertionAdapter = InsertionAdapter(
            database,
            'article',
            (ArticleModel item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'description': item.description,
                  'content': item.content,
                  'authorId': item.authorId,
                  'authorName': item.authorName,
                  'thumbnailUrl': item.thumbnailUrl,
                  'thumbnailPath': item.thumbnailPath,
                  'url': item.url,
                  'publishedAt': item.publishedAt,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt,
                  'status': item.status,
                  'isDeleted':
                      item.isDeleted == null ? null : (item.isDeleted! ? 1 : 0),
                  'readingTimeMinutes': item.readingTimeMinutes
                }),
        _articleModelDeletionAdapter = DeletionAdapter(
            database,
            'article',
            ['id'],
            (ArticleModel item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'description': item.description,
                  'content': item.content,
                  'authorId': item.authorId,
                  'authorName': item.authorName,
                  'thumbnailUrl': item.thumbnailUrl,
                  'thumbnailPath': item.thumbnailPath,
                  'url': item.url,
                  'publishedAt': item.publishedAt,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt,
                  'status': item.status,
                  'isDeleted':
                      item.isDeleted == null ? null : (item.isDeleted! ? 1 : 0),
                  'readingTimeMinutes': item.readingTimeMinutes
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
            id: row['id'] as String?,
            authorName: row['authorName'] as String?,
            title: row['title'] as String?,
            description: row['description'] as String?,
            url: row['url'] as String?,
            thumbnailUrl: row['thumbnailUrl'] as String?,
            publishedAt: row['publishedAt'] as String?,
            content: row['content'] as String?,
            authorId: row['authorId'] as String?,
            thumbnailPath: row['thumbnailPath'] as String?,
            createdAt: row['createdAt'] as String?,
            updatedAt: row['updatedAt'] as String?,
            status: row['status'] as String?,
            isDeleted: row['isDeleted'] == null
                ? null
                : (row['isDeleted'] as int) != 0,
            readingTimeMinutes: row['readingTimeMinutes'] as int?));
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
