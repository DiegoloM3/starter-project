import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/saved_article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/saved_article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/saved_article_repository.dart';

/// Bookmarks live in SQLite on the device, filed under the signed-in account,
/// so two people sharing a phone never see each other's list.
class SavedArticleRepositoryImpl implements SavedArticleRepository {
  final SavedArticleDao _dao;
  final AuthRepository _auth;

  const SavedArticleRepositoryImpl(this._dao, this._auth);

  static const String _storageErrorMessage = 'Could not access your saved articles.';

  @override
  Future<DataState<List<ArticleEntity>>> getSavedArticles() {
    return _asOwner((owner) async {
      final models = await _dao.getArticles(owner);
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<DataState<void>> saveArticle(ArticleEntity article) {
    return _asOwner((owner) => _dao.insertArticle(SavedArticleModel.fromEntity(article, ownerId: owner)));
  }

  @override
  Future<DataState<void>> removeArticle(String id) {
    return _asOwner((owner) => _dao.deleteById(owner, id));
  }


  Future<DataState<T>> _asOwner<T>(Future<T> Function(String ownerId) operation) async {
    final user = _auth.currentUser;
    if (user == null) return const DataFailed(Failure.unauthenticated());
    return runGuarded(() => operation(user.id), onError: (_) => const Failure.unknown(_storageErrorMessage));
  }
}
