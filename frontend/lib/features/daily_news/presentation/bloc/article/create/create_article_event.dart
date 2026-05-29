import '../../../../domain/entities/article.dart';

abstract class CreateArticleEvent {
  const CreateArticleEvent();
}

class ExistingDraftLoaded extends CreateArticleEvent {
  final ArticleEntity article;

  const ExistingDraftLoaded(this.article);
}

class TitleChanged extends CreateArticleEvent {
  final String title;

  const TitleChanged(this.title);
}

class DescriptionChanged extends CreateArticleEvent {
  final String description;

  const DescriptionChanged(this.description);
}

class ContentChanged extends CreateArticleEvent {
  final String content;

  const ContentChanged(this.content);
}

class ThumbnailSelected extends CreateArticleEvent {
  final String filePath;

  const ThumbnailSelected(this.filePath);
}

class ThumbnailRemoved extends CreateArticleEvent {
  const ThumbnailRemoved();
}

class AutosaveRequested extends CreateArticleEvent {
  const AutosaveRequested();
}

class DraftSaveRequested extends CreateArticleEvent {
  const DraftSaveRequested();
}

class PublishRequested extends CreateArticleEvent {
  const PublishRequested();
}

class ArchiveRequested extends CreateArticleEvent {
  const ArchiveRequested();
}
