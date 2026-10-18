import 'package:equatable/equatable.dart';

import 'article_content.dart';
import 'article_topic.dart';

class ArticleEntity extends Equatable {
  static const int _wordsReadPerMinute = 200;

  final String id;
  final String title;
  final String description;
  final ArticleContent content;
  final String thumbnailURL;
  final List<ArticleTopic> topics;
  final DateTime publishedAt;
  final String authorId;
  final String authorName;

  const ArticleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.thumbnailURL,
    required this.topics,
    required this.publishedAt,
    required this.authorId,
    required this.authorName,
  });

  bool isAuthoredBy(String? userId) => userId != null && userId == authorId;

  int get readingTimeInMinutes {
    final minutes = (content.wordCount / _wordsReadPerMinute).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  ArticleEntity copyWith({
    String? title,
    String? description,
    ArticleContent? content,
    String? thumbnailURL,
    List<ArticleTopic>? topics,
  }) {
    return ArticleEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      thumbnailURL: thumbnailURL ?? this.thumbnailURL,
      topics: topics ?? this.topics,
      publishedAt: publishedAt,
      authorId: authorId,
      authorName: authorName,
    );
  }

  @override
  List<Object?> get props => [id, title, description, content, thumbnailURL, topics, publishedAt, authorId, authorName];
}
