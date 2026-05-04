import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/saved_articles_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// One-shot Floor → Firestore migration of saved articles. Idempotent via
// `migratedKey`; second runs are no-ops. The flag is only set after a
// successful pass so failures are retried on the next launch.
class SavedArticlesMigration {
  final ArticleDao _articleDao;
  final SavedArticlesService _service;
  final FirebaseAuth _firebaseAuth;
  final SharedPreferences _prefs;

  static const String migratedKey = 'savedArticles.migratedToFirestore.v1';

  SavedArticlesMigration(
    this._articleDao,
    this._service,
    this._firebaseAuth,
    this._prefs,
  );

  Future<void> run() async {
    if (_prefs.getBool(migratedKey) == true) return;

    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final localArticles = await _articleDao.getArticles();
      for (final article in localArticles) {
        await _service.saveArticle(user.uid, article.toEntity());
      }
      await _prefs.setBool(migratedKey, true);
    } catch (e) {
      debugPrint('SavedArticlesMigration failed: $e');
    }
  }
}
