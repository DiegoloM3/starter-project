import 'package:equatable/equatable.dart';

class CreateArticleParams extends Equatable {
  final String title;
  final String content;
  final String author;
  final String? description;
  final String? category;
  final String thumbnailPath;

  const CreateArticleParams({
    required this.title,
    required this.content,
    required this.author,
    required this.thumbnailPath,
    this.description,
    this.category,
  });

  @override
  List<Object?> get props => [
        title,
        content,
        author,
        description,
        category,
        thumbnailPath,
      ];
}

class UpdateArticleParams extends Equatable {
  final String articleId;
  final String title;
  final String content;
  final String author;
  final String? description;
  final String? category;
  final String? thumbnailPath;

  const UpdateArticleParams({
    required this.articleId,
    required this.title,
    required this.content,
    required this.author,
    this.description,
    this.category,
    this.thumbnailPath,
  });

  @override
  List<Object?> get props => [
        articleId,
        title,
        content,
        author,
        description,
        category,
        thumbnailPath,
      ];
}

class DeleteArticleParams extends Equatable {
  final String articleId;

  const DeleteArticleParams({
    required this.articleId,
  });

  @override
  List<Object?> get props => [articleId];
}

class GetUserArticlesParams extends Equatable {
  final String userId;
  final int limit;
  final String? cursor;

  const GetUserArticlesParams({
    required this.userId,
    this.limit = 10,
    this.cursor,
  });

  @override
  List<Object?> get props => [userId, limit, cursor];
}

class UpdatePublishStatusParams extends Equatable {
  final String articleId;
  final bool isPublished;

  const UpdatePublishStatusParams({
    required this.articleId,
    required this.isPublished,
  });

  @override
  List<Object?> get props => [articleId, isPublished];
}
