import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_location.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';

sealed class UploadArticleEvent extends Equatable {
  const UploadArticleEvent();

  @override
  List<Object?> get props => [];
}

final class StartNewArticleEvent extends UploadArticleEvent {
  const StartNewArticleEvent();
}

final class LoadDraftEvent extends UploadArticleEvent {
  final int draftId;
  const LoadDraftEvent(this.draftId);

  @override
  List<Object?> get props => [draftId];
}

final class LoadArticleForEditEvent extends UploadArticleEvent {
  final JournalistArticleEntity article;
  const LoadArticleForEditEvent(this.article);

  @override
  List<Object?> get props => [article];
}

final class PickThumbnailEvent extends UploadArticleEvent {
  final ImageSource source;
  const PickThumbnailEvent(this.source);

  @override
  List<Object?> get props => [source];
}

final class TitleChangedEvent extends UploadArticleEvent {
  final String value;
  const TitleChangedEvent(this.value);

  @override
  List<Object?> get props => [value];
}

final class DescriptionChangedEvent extends UploadArticleEvent {
  final String value;
  const DescriptionChangedEvent(this.value);

  @override
  List<Object?> get props => [value];
}

final class ContentChangedEvent extends UploadArticleEvent {
  final String value;
  const ContentChangedEvent(this.value);

  @override
  List<Object?> get props => [value];
}

final class CategoryChangedEvent extends UploadArticleEvent {
  final ArticleCategory category;
  const CategoryChangedEvent(this.category);

  @override
  List<Object?> get props => [category];
}

final class TagsChangedEvent extends UploadArticleEvent {
  final List<String> tags;
  const TagsChangedEvent(this.tags);

  @override
  List<Object?> get props => [tags];
}

final class LanguageChangedEvent extends UploadArticleEvent {
  final String language;
  const LanguageChangedEvent(this.language);

  @override
  List<Object?> get props => [language];
}

final class LocationToggleEvent extends UploadArticleEvent {
  final ArticleLocation? location;
  const LocationToggleEvent(this.location);

  @override
  List<Object?> get props => [location];
}

final class AutoSaveDraftTickEvent extends UploadArticleEvent {
  const AutoSaveDraftTickEvent();
}

final class SaveDraftManuallyEvent extends UploadArticleEvent {
  const SaveDraftManuallyEvent();
}

final class PublishEvent extends UploadArticleEvent {
  const PublishEvent();
}

final class ResetEvent extends UploadArticleEvent {
  const ResetEvent();
}
