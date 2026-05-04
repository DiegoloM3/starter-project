import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/models/draft_article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase database;

  DraftArticleModel makeDraft({
    int? draftId,
    String title = 'Test Draft',
    String description = 'Description',
    String content = 'Content body',
    String language = 'en',
    String tagsRaw = 'dart,flutter',
    int? lastSavedAtMillis,
  }) {
    return DraftArticleModel(
      draftId: draftId,
      title: title,
      description: description,
      content: content,
      tagsRaw: tagsRaw,
      language: language,
      lastSavedAtMillis:
          lastSavedAtMillis ?? DateTime(2024, 6, 15).millisecondsSinceEpoch,
    );
  }

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = await $FloorAppDatabase
        .inMemoryDatabaseBuilder()
        .addMigrations([migration1to2])
        .build();
  });

  tearDown(() async {
    await database.close();
  });

  group('DraftDao', () {
    group('upsertDraft / getDraft', () {
      test('insert and query back returns matching draft', () async {
        final draft = makeDraft(title: 'My Article');
        final insertedId = await database.draftDao.upsertDraft(draft);

        final retrieved = await database.draftDao.getDraft(insertedId);

        expect(retrieved, isNotNull);
        expect(retrieved!.title, equals('My Article'));
        expect(retrieved.tagsRaw, equals('dart,flutter'));
        expect(retrieved.language, equals('en'));
      });

      test('getDraft returns null for non-existent id', () async {
        final result = await database.draftDao.getDraft(9999);
        expect(result, isNull);
      });

      test('upsert with same draftId replaces existing record', () async {
        final original = makeDraft(title: 'Original');
        final insertedId = await database.draftDao.upsertDraft(original);

        final updated = DraftArticleModel(
          draftId: insertedId,
          title: 'Updated Title',
          description: 'Updated description',
          content: 'Updated content',
          tagsRaw: 'new,tags',
          language: 'es',
          lastSavedAtMillis: DateTime(2025, 1, 1).millisecondsSinceEpoch,
        );
        await database.draftDao.upsertDraft(updated);

        final retrieved = await database.draftDao.getDraft(insertedId);
        expect(retrieved!.title, equals('Updated Title'));
        expect(retrieved.language, equals('es'));
        expect(retrieved.tagsRaw, equals('new,tags'));
      });
    });

    group('deleteDraft', () {
      test('delete removes the draft', () async {
        final draft = makeDraft(title: 'To delete');
        final insertedId = await database.draftDao.upsertDraft(draft);

        await database.draftDao.deleteDraft(insertedId);

        final result = await database.draftDao.getDraft(insertedId);
        expect(result, isNull);
      });

      test('deleteAllDrafts removes all records', () async {
        await database.draftDao.upsertDraft(makeDraft(title: 'A'));
        await database.draftDao.upsertDraft(makeDraft(title: 'B'));

        await database.draftDao.deleteAllDrafts();

        final stream = database.draftDao.watchDrafts();
        final list = await stream.first;
        expect(list, isEmpty);
      });
    });

    group('watchDrafts', () {
      test('emits current state on subscription', () async {
        await database.draftDao.upsertDraft(makeDraft(title: 'Watch me'));

        final list = await database.draftDao.watchDrafts().first;
        expect(list.length, equals(1));
        expect(list.first.title, equals('Watch me'));
      });

      test('returns drafts ordered by lastSavedAtMillis DESC', () async {
        final older = makeDraft(
          title: 'Older',
          lastSavedAtMillis: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        );
        final newer = makeDraft(
          title: 'Newer',
          lastSavedAtMillis: DateTime(2024, 6, 1).millisecondsSinceEpoch,
        );
        await database.draftDao.upsertDraft(older);
        await database.draftDao.upsertDraft(newer);

        final list = await database.draftDao.watchDrafts().first;
        expect(list.first.title, equals('Newer'));
        expect(list.last.title, equals('Older'));
      });

      test('empty database emits empty list', () async {
        final list = await database.draftDao.watchDrafts().first;
        expect(list, isEmpty);
      });
    });

    group('nullable fields', () {
      test('localImagePath, categoryRaw, location columns are nullable', () async {
        final draft = DraftArticleModel(
          title: 'Minimal',
          description: 'Desc',
          content: 'Content',
          tagsRaw: '',
          language: 'en',
          lastSavedAtMillis: DateTime(2024, 6, 15).millisecondsSinceEpoch,
        );
        final id = await database.draftDao.upsertDraft(draft);
        final retrieved = await database.draftDao.getDraft(id);

        expect(retrieved!.localImagePath, isNull);
        expect(retrieved.categoryRaw, isNull);
        expect(retrieved.locationLat, isNull);
        expect(retrieved.locationLng, isNull);
        expect(retrieved.locationPlaceName, isNull);
      });
    });
  });

  group('AppDatabase migration', () {
    test('v2 database contains both articles and draft_articles tables', () async {
      final sqfliteDb = database.database;

      final articlesResult =
          await sqfliteDb.rawQuery("PRAGMA table_info('article')");
      expect(articlesResult, isNotEmpty);

      final draftResult =
          await sqfliteDb.rawQuery("PRAGMA table_info('draft_articles')");
      expect(draftResult, isNotEmpty);
    });

    test('draft_articles table has expected columns', () async {
      final sqfliteDb = database.database;
      final columns = await sqfliteDb.rawQuery(
          "PRAGMA table_info('draft_articles')");

      final columnNames = columns.map((c) => c['name'] as String).toSet();
      expect(columnNames, containsAll([
        'draftId',
        'title',
        'description',
        'content',
        'localImagePath',
        'categoryRaw',
        'tagsRaw',
        'language',
        'locationLat',
        'locationLng',
        'locationPlaceName',
        'lastSavedAtMillis',
      ]));
    });
  });
}
