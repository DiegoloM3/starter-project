import '../entities/article_upload_entity.dart';

abstract class ArticleUploadRepository {
  Future<ArticleUploadEntity> uploadArticle(ArticleUploadEntity article);

  Future<String> uploadThumbnail({
    required String localFilePath,
    required String authorId,
  });

  Future<List<ArticleUploadEntity>> getMyArticles(String authorId);

  Future<List<ArticleUploadEntity>> getAllArticles();

  Future<void> incrementArticleViews(String articleId);
}
