import '../entities/article_upload_entity.dart';
import '../repository/article_upload_repository.dart';

class UploadArticleParams {
  final String title;
  final String content;
  final String thumbnailUrl;
  final String authorId;
  final String authorName;
  final List<String> tags;

  const UploadArticleParams({
    required this.title,
    required this.content,
    required this.thumbnailUrl,
    required this.authorId,
    required this.authorName,
    required this.tags,
  });
}

class UploadArticleUseCase {
  final ArticleUploadRepository _repository;

  UploadArticleUseCase(this._repository);

  Future<ArticleUploadEntity> call(UploadArticleParams params) {
    final now = DateTime.now();

    final article = ArticleUploadEntity(
      title: params.title,
      content: params.content,
      thumbnailUrl: params.thumbnailUrl,
      authorId: params.authorId,
      authorName: params.authorName,
      createdAt: now,
      updatedAt: now,
      readTime: ArticleUploadEntity.calculateReadTime(params.content),
      tags: params.tags,
      isPublished: true,
    );

    return _repository.uploadArticle(article);
  }
}
