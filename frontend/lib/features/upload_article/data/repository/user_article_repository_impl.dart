import 'package:news_app_clean_architecture/features/upload_article/data/data_sources/firestore_article_data_source.dart';
import 'package:news_app_clean_architecture/features/upload_article/data/data_sources/storage_article_data_source.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/user_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/params/upload_article_params.dart';

class UserArticleRepositoryDeps {
  final FirestoreArticleDataSource firestore;
  final StorageArticleDataSource storage;

  const UserArticleRepositoryDeps({
    required this.firestore,
    required this.storage,
  });
}

class UserArticleRepositoryImpl implements UserArticleRepository {
  final UserArticleRepositoryDeps _deps;

  UserArticleRepositoryImpl(this._deps);

  FirestoreArticleDataSource get _firestore => _deps.firestore;
  StorageArticleDataSource get _storage => _deps.storage;

  @override
  Future<UserArticleEntity> uploadArticle(UploadArticleParams params) async {
    final articleId = _firestore.newArticleId();
    String? uploadedPath;
    try {
      final upload =
          await _storage.uploadThumbnailForCurrentUser(ThumbnailUploadRequest(
        articleId: articleId,
        bytes: params.thumbnailBytes,
        fileName: params.thumbnailFileName,
      ));
      uploadedPath = upload.path;
      final model = await _firestore
          .createArticleForCurrentUser(ArticleCreateRequest(
        id: articleId,
        title: params.title.trim(),
        description: params.description.trim(),
        content: params.content.trim(),
        thumbnailUrl: upload.downloadUrl,
        thumbnailPath: upload.path,
      ));
      return model.toEntity();
    } catch (_) {
      if (uploadedPath != null) {
        await _storage.deleteByPath(uploadedPath);
      }
      rethrow;
    }
  }

  @override
  Future<UserArticleEntity> updateArticle(UpdateArticleParams params) async {
    String? newUrl;
    String? newPath;
    final bytes = params.newThumbnailBytes;
    final fileName = params.newThumbnailFileName;
    if (bytes != null && bytes.isNotEmpty && fileName != null) {
      final upload = await _storage.uploadThumbnailForCurrentUser(
        ThumbnailUploadRequest(
          articleId: params.articleId,
          bytes: bytes,
          fileName: fileName,
        ),
      );
      newUrl = upload.downloadUrl;
      newPath = upload.path;
    }
    final model =
        await _firestore.updateArticleForCurrentUser(ArticleUpdateRequest(
      articleId: params.articleId,
      title: params.title.trim(),
      description: params.description.trim(),
      content: params.content.trim(),
      newThumbnailUrl: newUrl,
      newThumbnailPath: newPath,
    ));
    return model.toEntity();
  }

  @override
  Future<List<UserArticleEntity>> getMyArticles() async {
    final models = await _firestore.getMyArticles();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<UserArticleEntity>> getAllUserArticles() async {
    final models = await _firestore.getAllArticles();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> refreshAuthorSnapshotsForCurrentUser() =>
      _firestore.refreshAuthorSnapshotsForCurrentUser();

  @override
  Future<void> deleteArticle(String articleId) async {
    final thumbnailPath =
        await _firestore.deleteArticleForCurrentUser(articleId);
    if (thumbnailPath != null) {
      await _storage.deleteByPath(thumbnailPath);
    }
  }
}
