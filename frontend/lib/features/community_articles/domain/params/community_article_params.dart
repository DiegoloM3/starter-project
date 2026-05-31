import 'dart:io';

/// Parameters for loading paginated community articles.
///
/// Pass [lastDocumentId] to fetch the next cursor page.
class CommunityArticleParams {
  final int pageSize;
  final String? lastDocumentId;

  const CommunityArticleParams({this.pageSize = 20, this.lastDocumentId});
}

/// Parameters for loading a community article by ID.
class GetArticleByIdParams {
  final String id;

  const GetArticleByIdParams({required this.id});
}

/// Parameters for loading articles owned by a user.
class GetUserArticlesParams {
  final String userId;

  const GetUserArticlesParams({required this.userId});
}

/// Parameters for creating a community article.
class CreateArticleParams {
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? description;
  final File? imageFile;
  final String? category;

  const CreateArticleParams({
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.description,
    this.imageFile,
    this.category,
  });
}

/// Parameters for updating a community article.
///
/// Only non-null fields are updated. Set [removeImage] to true to
/// explicitly delete the current image without replacing it.
class UpdateArticleParams {
  final String id;
  final String authorId;
  final String? title;
  final String? content;
  final String? description;
  final File? imageFile;
  final bool removeImage;
  final String? category;

  const UpdateArticleParams({
    required this.id,
    required this.authorId,
    this.title,
    this.content,
    this.description,
    this.imageFile,
    this.removeImage = false,
    this.category,
  });
}

/// Parameters for deleting a community article.
class DeleteArticleParams {
  final String id;

  const DeleteArticleParams({required this.id});
}
