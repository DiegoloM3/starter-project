import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/shared/media/domain/entities/local_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// An unfinished new article, kept on the device so leaving the Write screen
/// does not lose what was typed. There is only ever one: the next visit to
/// Write picks it up where it was left.
class SavedDraft extends Equatable {
  final String title;
  final String description;
  final String content;
  final NewsCategory category;

  /// The photo picked for the article, if any. It is a device file, so it may
  /// have disappeared by the time the draft is restored.
  final LocalImage? image;

  const SavedDraft({
    this.title = '',
    this.description = '',
    this.content = '',
    this.category = NewsCategory.general,
    this.image,
  });

  /// Nothing worth keeping: every text is blank and there is no photo. The
  /// category alone is not content, it is a default.
  bool get isEmpty =>
      title.trim().isEmpty && description.trim().isEmpty && content.trim().isEmpty && image == null;

  bool get isNotEmpty => !isEmpty;

  SavedDraft copyWith({
    String? title,
    String? description,
    String? content,
    NewsCategory? category,
    LocalImage? image,
    bool clearImage = false,
  }) {
    return SavedDraft(
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      category: category ?? this.category,
      image: clearImage ? null : (image ?? this.image),
    );
  }

  @override
  List<Object?> get props => [title, description, content, category, image];
}
