import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';

class DraftArticle {
  final String title;
  final String body;
  final String? section;
  final String author;

  const DraftArticle({
    required this.title,
    required this.body,
    this.section,
    required this.author,
  });
}

class DraftService {
  final AppDatabase _appDatabase;

  DraftService(this._appDatabase);

  static const _tableName = 'draft_article';

  Future<void> ensureTableCreated() async {
    await _appDatabase.database.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        section TEXT,
        author TEXT NOT NULL
      )
    ''');
  }

  Future<void> saveDraft(DraftArticle draft) async {
    final db = _appDatabase.database;
    await db.execute('DELETE FROM $_tableName');
    await db.insert(_tableName, {
      'id': 1,
      'title': draft.title,
      'body': draft.body,
      'section': draft.section,
      'author': draft.author,
    });
  }

  Future<DraftArticle?> loadDraft() async {
    final rows = await _appDatabase.database.query(_tableName);
    if (rows.isEmpty) return null;
    final row = rows.first;
    return DraftArticle(
      title: row['title'] as String,
      body: row['body'] as String,
      section: row['section'] as String?,
      author: row['author'] as String,
    );
  }

  Future<void> clearDraft() async {
    await _appDatabase.database.execute('DELETE FROM $_tableName');
  }
}
