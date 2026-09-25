import 'dart:typed_data';

import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';

/// What the article form holds at one moment: its four text fields, plus a
/// photo picked in this session (null when none was picked -- the article
/// keeps whatever cover it already had).
class ArticleFormInput {
  final String authorName;
  final String title;
  final String description;
  final String content;
  final Uint8List? imageBytes;
  final String? imageExtension;

  const ArticleFormInput({
    required this.authorName,
    required this.title,
    required this.description,
    required this.content,
    this.imageBytes,
    this.imageExtension,
  });

  const ArticleFormInput.empty()
      : this(authorName: '', title: '', description: '', content: '');

  factory ArticleFormInput.fromArticle(UserArticleEntity article) {
    return ArticleFormInput(
      authorName: article.authorName,
      title: article.title,
      description: article.description,
      content: article.content,
    );
  }

  ArticleFormInput withAuthorName(String authorName) {
    return ArticleFormInput(
      authorName: authorName,
      title: title,
      description: description,
      content: content,
      imageBytes: imageBytes,
      imageExtension: imageExtension,
    );
  }

  ArticleFormInput withoutImage() {
    return ArticleFormInput(
      authorName: authorName,
      title: title,
      description: description,
      content: content,
    );
  }

  bool hasSameTextAs(ArticleFormInput other) {
    return authorName == other.authorName &&
        title == other.title &&
        description == other.description &&
        content == other.content;
  }

  /// Same photo as [other] -- by identity, not by comparing every byte: a
  /// photo only ever changes by picking a new one, which is a new list.
  bool hasSameImageAs(ArticleFormInput other) =>
      identical(imageBytes, other.imageBytes);
}
