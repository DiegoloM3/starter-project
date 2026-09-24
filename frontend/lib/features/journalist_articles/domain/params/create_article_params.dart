import 'package:equatable/equatable.dart';

import '../entities/article_status.dart';

/// Input of `CreateArticleUseCase`: the content a journalist typed in the
/// editor plus the status the article is created with (a draft that will be
/// finished later, or an article published right away).
class CreateArticleParams extends Equatable {
  final String title;
  final String description;
  final String content;
  final String author;
  final String userId;
  final String thumbnailUrl;
  final ArticleStatus status;

  const CreateArticleParams({
    required this.title,
    required this.author,
    required this.userId,
    this.description = '',
    this.content = '',
    this.thumbnailUrl = '',
    this.status = ArticleStatus.draft,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        content,
        author,
        userId,
        thumbnailUrl,
        status,
      ];
}
