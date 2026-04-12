import 'package:equatable/equatable.dart';

class ArticleUploadEntity extends Equatable {
  final String? id;
  final String title;
  final String description;
  final String content;
  final String author;
  final String authorUid;
  final String thumbnailURL;
  final String? sourceName;
  final DateTime publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  final DateTime? deletedAt;

  ArticleUploadEntity({
    this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    required this.authorUid,
    required this.thumbnailURL,
    this.sourceName,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  }) {
    _assertInvariants();
  }

  void _assertInvariants() {
    if (title.isEmpty || title.length > 120) {
      throw ArgumentError('title must be 1..120 chars, got ${title.length}');
    }
    if (description.isEmpty || description.length > 300) {
      throw ArgumentError(
        'description must be 1..300 chars, got ${description.length}',
      );
    }
    if (content.isEmpty || content.length > 20000) {
      throw ArgumentError(
        'content must be 1..20000 chars, got ${content.length}',
      );
    }
    if (author.isEmpty || author.length > 80) {
      throw ArgumentError('author must be 1..80 chars, got ${author.length}');
    }
    if (authorUid.isEmpty) {
      throw ArgumentError('authorUid must not be empty');
    }
    if (thumbnailURL.isEmpty) {
      throw ArgumentError('thumbnailURL must not be empty');
    }
    if (sourceName != null && sourceName!.length > 60) {
      throw ArgumentError(
        'sourceName must be at most 60 chars, got ${sourceName!.length}',
      );
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        author,
        authorUid,
        thumbnailURL,
        sourceName,
        publishedAt,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
