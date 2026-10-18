import '../entities/article_content.dart';
import '../entities/article_topic.dart';

/// Limits shared with the Firestore and Storage security rules.
class ArticleLimits {
  static const int titleMaxLength = 150;
  static const int descriptionMaxLength = 300;
  static const int contentMaxLength = 100000;
  static const int maxTopics = 3;
  static const int imageMaxBytes = 5 * 1024 * 1024;
}

enum ArticleValidationError {
  titleEmpty,
  titleTooLong,
  descriptionEmpty,
  descriptionTooLong,
  contentEmpty,
  contentTooLong,
  noTopics,
  tooManyTopics,
  imageEmpty,
  imageTooLarge,
}

/// The fields a journalist writes, shared by publishing and editing an article.
class ArticleDraft {
  final String title;
  final String description;
  final ArticleContent content;
  final Set<ArticleTopic> topics;

  ArticleDraft({
    required String title,
    required String description,
    required this.content,
    required this.topics,
  })  : title = title.trim(),
        description = description.trim();

  Set<ArticleValidationError> get validationErrors => {
        ..._titleErrors(),
        ..._descriptionErrors(),
        ..._contentErrors(),
        ..._topicErrors(),
      };

  Iterable<ArticleValidationError> _titleErrors() sync* {
    if (title.isEmpty) yield ArticleValidationError.titleEmpty;
    if (title.length > ArticleLimits.titleMaxLength) yield ArticleValidationError.titleTooLong;
  }

  Iterable<ArticleValidationError> _descriptionErrors() sync* {
    if (description.isEmpty) yield ArticleValidationError.descriptionEmpty;
    if (description.length > ArticleLimits.descriptionMaxLength) yield ArticleValidationError.descriptionTooLong;
  }

  Iterable<ArticleValidationError> _contentErrors() sync* {
    if (content.isEmpty) yield ArticleValidationError.contentEmpty;
    if (content.deltaJson.length > ArticleLimits.contentMaxLength) yield ArticleValidationError.contentTooLong;
  }

  Iterable<ArticleValidationError> _topicErrors() sync* {
    if (topics.isEmpty) yield ArticleValidationError.noTopics;
    if (topics.length > ArticleLimits.maxTopics) yield ArticleValidationError.tooManyTopics;
  }
}
