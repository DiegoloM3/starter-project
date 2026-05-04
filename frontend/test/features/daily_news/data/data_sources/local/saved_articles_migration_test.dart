import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/saved_articles_migration.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/saved_articles_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockDao extends Mock implements ArticleDao {}

class _MockService extends Mock implements SavedArticlesService {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockDao dao;
  late _MockService service;
  late _MockFirebaseAuth auth;
  late SharedPreferences prefs;
  late SavedArticlesMigration migration;

  setUpAll(() {
    registerFallbackValue(const ArticleEntity());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    dao = _MockDao();
    service = _MockService();
    auth = _MockFirebaseAuth();
    migration = SavedArticlesMigration(dao, service, auth, prefs);
  });

  ArticleModel _model(String url, String title) => ArticleModel(
        author: 'A',
        title: title,
        description: 'D',
        url: url,
        urlToImage: 'https://img/i.jpg',
        publishedAt: '2026-05-03T10:00:00Z',
        content: 'C',
      );

  void _stubAnonUid(String uid) {
    final user = _MockUser();
    when(() => user.uid).thenReturn(uid);
    when(() => auth.currentUser).thenReturn(user);
  }

  test('does nothing when migration flag is already set', () async {
    await prefs.setBool(SavedArticlesMigration.migratedKey, true);

    await migration.run();

    verifyNever(() => dao.getArticles());
    verifyNever(() => service.saveArticle(any(), any()));
  });

  test('does nothing when no Firebase user is signed in (deferred to next run)',
      () async {
    when(() => auth.currentUser).thenReturn(null);

    await migration.run();

    verifyNever(() => dao.getArticles());
    expect(prefs.getBool(SavedArticlesMigration.migratedKey), isNull);
  });

  test('copies all Floor articles to Firestore for the current uid',
      () async {
    _stubAnonUid('anon-1');
    when(() => dao.getArticles()).thenAnswer(
      (_) async => [
        _model('https://e.com/a-1', 'A1'),
        _model('https://e.com/a-2', 'A2'),
      ],
    );
    when(() => service.saveArticle(any(), any())).thenAnswer((_) async {});

    await migration.run();

    verify(() => service.saveArticle('anon-1', any())).called(2);
    expect(prefs.getBool(SavedArticlesMigration.migratedKey), isTrue);
  });

  test('marks migrated even when Floor has zero saves', () async {
    _stubAnonUid('anon-1');
    when(() => dao.getArticles()).thenAnswer((_) async => []);

    await migration.run();

    verifyNever(() => service.saveArticle(any(), any()));
    expect(prefs.getBool(SavedArticlesMigration.migratedKey), isTrue);
  });

  test('does NOT mark migrated when the service throws — next run retries',
      () async {
    _stubAnonUid('anon-1');
    when(() => dao.getArticles()).thenAnswer(
      (_) async => [_model('https://e.com/a', 'A')],
    );
    when(() => service.saveArticle(any(), any()))
        .thenThrow(StateError('firestore offline'));

    await migration.run();

    expect(prefs.getBool(SavedArticlesMigration.migratedKey), isNull);
  });

  test('skips work on second run after a successful first run', () async {
    _stubAnonUid('anon-1');
    when(() => dao.getArticles()).thenAnswer(
      (_) async => [_model('https://e.com/a', 'A')],
    );
    when(() => service.saveArticle(any(), any())).thenAnswer((_) async {});

    await migration.run();
    await migration.run();

    verify(() => dao.getArticles()).called(1);
    verify(() => service.saveArticle(any(), any())).called(1);
  });
}
