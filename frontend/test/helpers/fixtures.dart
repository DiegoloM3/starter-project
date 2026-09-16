import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/shared/media/domain/entities/local_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/thumbnail_reference.dart';

/// Test data builders. Every field has a sensible default so a test only
/// spells out what matters to it.
ArticleEntity buildArticle({
  String id = 'article-1',
  ArticleSource source = ArticleSource.remote,
  String title = 'Title',
  String content = 'Content',
  String? description = 'Description',
  String author = 'Ada',
  NewsCategory category = NewsCategory.general,
  String? authorId,
  String? imageUrl = 'https://img.example/1.jpg',
  String? imagePath,
  String? url,
  DateTime? publishedAt,
}) {
  return ArticleEntity(
    id: id,
    source: source,
    title: title,
    content: content,
    description: description,
    author: author,
    category: category,
    authorId: authorId,
    imageUrl: imageUrl,
    imagePath: imagePath,
    url: url,
    publishedAt: publishedAt ?? DateTime.utc(2026, 9, 15, 10),
  );
}

ArticleEntity buildUserArticle({
  String id = 'doc-1',
  String authorId = 'uid-1',
  String? imageUrl = 'https://storage.example/media%2Farticles%2F1.jpg?alt=media',
  String? imagePath = 'media/articles/1.jpg',
  DateTime? publishedAt,
}) {
  return buildArticle(
    id: id,
    source: ArticleSource.user,
    authorId: authorId,
    imageUrl: imageUrl,
    imagePath: imagePath,
    publishedAt: publishedAt,
  );
}

ArticleDraft buildDraft({
  String title = 'A valid title',
  String content = 'A valid body.',
  String? description = 'A valid summary.',
  DateTime? publishedAt,
}) {
  return ArticleDraft(
    title: title,
    content: content,
    description: description,
    publishedAt: publishedAt ?? DateTime.utc(2026, 9, 15, 10),
  );
}

LocalImage buildImage({
  String path = '/tmp/photo.jpg',
  String mimeType = 'image/jpeg',
  int sizeInBytes = 1024,
}) {
  return LocalImage(path: path, mimeType: mimeType, sizeInBytes: sizeInBytes);
}

const ThumbnailReference thumbnailReference = ThumbnailReference(
  url: 'https://storage.example/media%2Farticles%2Fnew.jpg?alt=media',
  path: 'media/articles/new.jpg',
);

const UserEntity user = UserEntity(
  id: 'uid-1',
  email: 'ada@example.com',
  displayName: 'Ada Lovelace',
);
