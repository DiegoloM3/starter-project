// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
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

  SavedArticleDao? _savedArticleDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 4,
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
            'CREATE TABLE IF NOT EXISTS `saved_article` (`ownerId` TEXT NOT NULL, `id` TEXT NOT NULL, `source` TEXT NOT NULL, `title` TEXT NOT NULL, `content` TEXT NOT NULL, `description` TEXT, `author` TEXT NOT NULL, `category` TEXT NOT NULL, `authorId` TEXT, `imageUrl` TEXT, `imagePath` TEXT, `url` TEXT, `publishedAt` INTEGER NOT NULL, PRIMARY KEY (`ownerId`, `id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  SavedArticleDao get savedArticleDao {
    return _savedArticleDaoInstance ??=
        _$SavedArticleDao(database, changeListener);
  }
}

class _$SavedArticleDao extends SavedArticleDao {
  _$SavedArticleDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _savedArticleModelInsertionAdapter = InsertionAdapter(
            database,
            'saved_article',
            (SavedArticleModel item) => <String, Object?>{
                  'ownerId': item.ownerId,
                  'id': item.id,
                  'source': _articleSourceConverter.encode(item.source),
                  'title': item.title,
                  'content': item.content,
                  'description': item.description,
                  'author': item.author,
                  'category': _newsCategoryConverter.encode(item.category),
                  'authorId': item.authorId,
                  'imageUrl': item.imageUrl,
                  'imagePath': item.imagePath,
                  'url': item.url,
                  'publishedAt': _dateTimeConverter.encode(item.publishedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<SavedArticleModel> _savedArticleModelInsertionAdapter;

  @override
  Future<List<SavedArticleModel>> getArticles(String ownerId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM saved_article WHERE ownerId = ?1 ORDER BY publishedAt DESC',
        mapper: (Map<String, Object?> row) => SavedArticleModel(
            ownerId: row['ownerId'] as String,
            id: row['id'] as String,
            source: _articleSourceConverter.decode(row['source'] as String),
            title: row['title'] as String,
            content: row['content'] as String,
            author: row['author'] as String,
            publishedAt: _dateTimeConverter.decode(row['publishedAt'] as int),
            category: _newsCategoryConverter.decode(row['category'] as String),
            description: row['description'] as String?,
            authorId: row['authorId'] as String?,
            imageUrl: row['imageUrl'] as String?,
            imagePath: row['imagePath'] as String?,
            url: row['url'] as String?),
        arguments: [ownerId]);
  }

  @override
  Future<SavedArticleModel?> findById(String ownerId, String id) async {
    return _queryAdapter.query(
        'SELECT * FROM saved_article WHERE ownerId = ?1 AND id = ?2',
        mapper: (Map<String, Object?> row) => SavedArticleModel(
            ownerId: row['ownerId'] as String,
            id: row['id'] as String,
            source: _articleSourceConverter.decode(row['source'] as String),
            title: row['title'] as String,
            content: row['content'] as String,
            author: row['author'] as String,
            publishedAt: _dateTimeConverter.decode(row['publishedAt'] as int),
            category: _newsCategoryConverter.decode(row['category'] as String),
            description: row['description'] as String?,
            authorId: row['authorId'] as String?,
            imageUrl: row['imageUrl'] as String?,
            imagePath: row['imagePath'] as String?,
            url: row['url'] as String?),
        arguments: [ownerId, id]);
  }

  @override
  Future<void> deleteById(String ownerId, String id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM saved_article WHERE ownerId = ?1 AND id = ?2',
        arguments: [ownerId, id]);
  }

  @override
  Future<void> insertArticle(SavedArticleModel article) async {
    await _savedArticleModelInsertionAdapter.insert(
        article, OnConflictStrategy.replace);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
final _articleSourceConverter = ArticleSourceConverter();
final _newsCategoryConverter = NewsCategoryConverter();
