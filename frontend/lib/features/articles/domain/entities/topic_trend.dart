import 'package:equatable/equatable.dart';

import 'article.dart';
import 'article_topic.dart';

/// A topic and its recent articles, newest first.
class TopicTrend extends Equatable {
  final ArticleTopic topic;
  final List<ArticleEntity> articles;

  const TopicTrend({required this.topic, required this.articles});

  int get articleCount => articles.length;

  @override
  List<Object?> get props => [topic, articles];
}
