import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/comment.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

const tEmail = 'test@example.com';
const tPassword = 'password123';
const tUserId = 'uid-1';
const tArticleId = 'article-1';
const tCommentId = 'comment-1';
const tAuthorName = 'Test Author';
const tThumbnailUrl = 'https://example.com/thumb.jpg';
const tFilePath = '/path/to/image.jpg';

ArticleEntity testArticle({
  String? id,
  String? title,
  String? description,
  String? content,
  String? authorId,
  String? authorName,
  String? thumbnailUrl,
  String? status,
  bool? isDeleted,
  int? readingTimeMinutes,
}) {
  return ArticleEntity(
    id: id ?? tArticleId,
    title: title ?? 'Test Article',
    description: description ?? 'Test Description',
    content: content ?? 'Test content body',
    authorId: authorId ?? tUserId,
    authorName: authorName ?? tAuthorName,
    thumbnailUrl: thumbnailUrl ?? tThumbnailUrl,
    thumbnailPath: '',
    url: 'https://example.com/article',
    publishedAt: '2026-01-01T00:00:00.000Z',
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-01T00:00:00.000Z',
    status: status ?? ArticleStatus.draft,
    isDeleted: isDeleted ?? false,
    readingTimeMinutes: readingTimeMinutes ?? 1,
  );
}

List<ArticleEntity> testArticleList({int count = 3}) {
  return List.generate(
    count,
    (i) => testArticle(id: 'article-$i', title: 'Article $i'),
  );
}

ArticleModel testArticleModel({
  String? id,
  String? title,
  String? status,
}) {
  return ArticleModel(
    id: id ?? tArticleId,
    title: title ?? 'Test Article',
    description: 'Test Description',
    content: 'Test content body',
    authorId: tUserId,
    authorName: tAuthorName,
    thumbnailUrl: tThumbnailUrl,
    thumbnailPath: '',
    url: 'https://example.com/article',
    publishedAt: '2026-01-01T00:00:00.000Z',
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-01T00:00:00.000Z',
    status: status ?? ArticleStatus.draft,
    isDeleted: false,
    readingTimeMinutes: 1,
  );
}

List<ArticleModel> testArticleModelList({int count = 3}) {
  return List.generate(
    count,
    (i) => testArticleModel(id: 'article-$i', title: 'Article $i'),
  );
}

CommentEntity testComment({
  String? id,
  String? articleId,
  String? authorId,
  String? content,
}) {
  return CommentEntity(
    id: id ?? tCommentId,
    articleId: articleId ?? tArticleId,
    authorId: authorId ?? tUserId,
    authorName: tAuthorName,
    content: content ?? 'Test comment',
    createdAt: '2026-01-01T00:00:00.000Z',
    isDeleted: false,
  );
}

List<CommentEntity> testCommentList({int count = 3, String? articleId}) {
  return List.generate(
    count,
    (i) => testComment(
      id: 'comment-$i',
      articleId: articleId,
      content: 'Comment $i',
    ),
  );
}

CommentModel testCommentModel({
  String? id,
  String? articleId,
}) {
  return CommentModel(
    id: id ?? tCommentId,
    articleId: articleId ?? tArticleId,
    authorId: tUserId,
    authorName: tAuthorName,
    content: 'Test comment',
    createdAt: '2026-01-01T00:00:00.000Z',
    isDeleted: false,
  );
}

AuthUserEntity testAuthUser({
  String? uid,
  String? email,
  String? displayName,
}) {
  return AuthUserEntity(
    uid: uid ?? tUserId,
    email: email ?? tEmail,
    displayName: displayName ?? tAuthorName,
  );
}
