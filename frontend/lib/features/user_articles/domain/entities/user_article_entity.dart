import 'dart:math';

import 'package:equatable/equatable.dart';

class UserArticleEntity extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String description;
  final String content;
  final String thumbnailURL;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// A draft is only ever visible to its own author (see firestore.rules)
  /// and skips the validation a published article has to meet -- it can be
  /// missing a title, a photo, anything, since it's explicitly a work in
  /// progress rather than a finished piece.
  final bool isDraft;

  const UserArticleEntity({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.description,
    required this.content,
    required this.thumbnailURL,
    required this.createdAt,
    required this.updatedAt,
    this.isDraft = false,
  });

  /// An average adult's silent reading pace.
  static const wordsPerMinute = 200;

  static final _hasLetterOrDigit = RegExp(r'[\p{L}\p{N}]', unicode: true);

  /// How long [content] takes to read, rounded up and never under a
  /// minute. Formatting markers ("**", "## ", "- ") aren't words, so they
  /// don't count.
  int get readingMinutes {
    final words = content
        .split(RegExp(r'\s+'))
        .where(_hasLetterOrDigit.hasMatch)
        .length;
    return max(1, (words / wordsPerMinute).ceil());
  }

  @override
  List<Object?> get props => [
        id,
        authorId,
        authorName,
        title,
        description,
        content,
        thumbnailURL,
        createdAt,
        updatedAt,
        isDraft,
      ];
}
