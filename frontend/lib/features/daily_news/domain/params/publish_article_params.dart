import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/shared/media/domain/entities/local_image.dart';

/// Input for publishing a brand-new article.
class PublishArticleParams extends Equatable {
  final ArticleDraft draft;

  /// Optional thumbnail picked on the device.
  final LocalImage? thumbnail;

  const PublishArticleParams({required this.draft, this.thumbnail});

  @override
  List<Object?> get props => [draft, thumbnail];
}

/// Input for editing an article the current user already published.
class UpdateArticleParams extends Equatable {
  /// The article as it currently exists.
  final ArticleEntity article;

  /// The edited text fields.
  final ArticleDraft draft;

  /// A new thumbnail to upload, replacing the current one if any.
  final LocalImage? newThumbnail;

  /// Whether to drop the current thumbnail without adding a new one.
  final bool removeThumbnail;

  const UpdateArticleParams({
    required this.article,
    required this.draft,
    this.newThumbnail,
    this.removeThumbnail = false,
  });

  @override
  List<Object?> get props => [article, draft, newThumbnail, removeThumbnail];
}
