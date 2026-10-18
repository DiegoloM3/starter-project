import '../../domain/entities/article.dart';
import '../../domain/entities/article_content.dart';
import '../../domain/entities/article_topic.dart';

/// Article stored in `articles/{articleId}`. The data source converts the Firestore timestamps
/// to [DateTime] first, so this model does not depend on Firebase.
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.description,
    required super.content,
    required super.thumbnailURL,
    required super.topics,
    required super.publishedAt,
    required super.authorId,
    required super.authorName,
  });

  factory ArticleModel.fromRawData(String id, Map<String, dynamic> data) {
    return ArticleModel(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      content: ArticleContent(data['content'] as String? ?? ''),
      thumbnailURL: data['thumbnailURL'] as String? ?? '',
      topics: _parseTopics(data['topics']),
      // Null while the server has not set it yet, right after publishing without connection.
      publishedAt: data['publishedAt'] as DateTime? ?? DateTime.now(),
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
    );
  }

  /// Topics added to the server after this version of the app was released are skipped.
  static List<ArticleTopic> _parseTopics(Object? rawTopics) {
    final topicIds = rawTopics is List ? rawTopics.whereType<String>() : const <String>[];
    return topicIds.map(ArticleTopic.fromId).whereType<ArticleTopic>().toList();
  }

  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      title: title,
      description: description,
      content: content,
      thumbnailURL: thumbnailURL,
      topics: topics,
      publishedAt: publishedAt,
      authorId: authorId,
      authorName: authorName,
    );
  }
}
