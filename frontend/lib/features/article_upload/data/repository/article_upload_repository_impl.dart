import '../../domain/entities/article_upload_entity.dart';
import '../../domain/repository/article_upload_repository.dart';
import '../data_sources/article_upload_remote_datasource.dart';
import '../models/article_upload_model.dart';

class ArticleUploadRepositoryImpl implements ArticleUploadRepository {
  final ArticleUploadRemoteDataSource _dataSource;

  ArticleUploadRepositoryImpl(this._dataSource);

  @override
  Future<ArticleUploadEntity> uploadArticle(
      ArticleUploadEntity article) async {
    final model = ArticleUploadModel(
      title: article.title,
      content: article.content,
      thumbnailUrl: article.thumbnailUrl,
      authorId: article.authorId,
      authorName: article.authorName,
      createdAt: article.createdAt,
      updatedAt: article.updatedAt,
      readTime: article.readTime,
      tags: article.tags,
      isPublished: article.isPublished,
      views: article.views,
      likes: article.likes,
    );
    final result = await _dataSource.uploadArticle(model);
    return result.toEntity();
  }

  @override
  Future<String> uploadThumbnail({
    required String localFilePath,
    required String authorId,
  }) {
    return _dataSource.uploadThumbnail(
      localFilePath: localFilePath,
      authorId: authorId,
    );
  }

  @override
  Future<List<ArticleUploadEntity>> getMyArticles(String authorId) async {
    final models = await _dataSource.getMyArticles(authorId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ArticleUploadEntity>> getAllArticles() async {
    final models = await _dataSource.getAllArticles();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> incrementArticleViews(String articleId) =>
      _dataSource.incrementArticleViews(articleId);
}
