import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';

/// Article as it is stored in the Firestore collection `articles` (backend/docs/DB_SCHEMA.md).
class JournalistArticleModel extends JournalistArticleEntity {
  const JournalistArticleModel({
    required super.id,
    required super.title,
    required super.description,
    required super.content,
    required super.author,
    required super.authorId,
    required super.thumbnailURL,
    required super.publishedAt,
    super.commentCount,
  });

  /// [rawData] holds the document fields with `publishedAt` already converted to a [DateTime], plus the
  /// `commentCount` counted by the data source (0 when it is missing, as for a new article).
  factory JournalistArticleModel.fromRawData(String id, Map<String, dynamic> rawData) {
    return JournalistArticleModel(
      id: id,
      title: rawData['title'] as String,
      description: rawData['description'] as String,
      content: rawData['content'] as String,
      author: rawData['author'] as String,
      authorId: rawData['authorId'] as String,
      thumbnailURL: rawData['thumbnailURL'] as String,
      publishedAt: rawData['publishedAt'] as DateTime,
      commentCount: rawData['commentCount'] as int? ?? 0,
    );
  }

  /// Fields that the journalist wrote in a new article. The data source adds the author, taken from the
  /// signed-in account, and `publishedAt`, set by the server.
  static Map<String, dynamic> buildRawDataOfNewArticle(ArticleDraftEntity draft, String thumbnailURL) {
    return {
      'title': draft.title,
      'description': draft.description,
      'content': draft.content,
      'thumbnailURL': thumbnailURL,
    };
  }

  JournalistArticleEntity toEntity() {
    return JournalistArticleEntity(
      id: id,
      title: title,
      description: description,
      content: content,
      author: author,
      authorId: authorId,
      thumbnailURL: thumbnailURL,
      publishedAt: publishedAt,
      commentCount: commentCount,
    );
  }
}
