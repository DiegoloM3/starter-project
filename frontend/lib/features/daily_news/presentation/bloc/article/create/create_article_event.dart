import '../../../../domain/entities/article.dart';

abstract class CreateArticleEvent {
  const CreateArticleEvent();
}

class LoadExistingDraft extends CreateArticleEvent {
  final ArticleEntity article;

  const LoadExistingDraft(this.article);
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

class SaveDraft extends CreateArticleEvent {
  const SaveDraft();
}

class PublishArticle extends CreateArticleEvent {
  const PublishArticle();
}

class ArchiveArticle extends CreateArticleEvent {
  const ArchiveArticle();
}
