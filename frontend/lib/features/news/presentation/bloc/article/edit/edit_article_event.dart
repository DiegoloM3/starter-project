part of 'edit_article_bloc.dart';

/// Events consumed by [EditArticleBloc].
abstract class EditArticleEvent extends Equatable {
  const EditArticleEvent();

  @override
  List<Object?> get props => [];
}

class SaveArticleEdits extends EditArticleEvent {
  final ArticleEntity original;
  final String title;
  final String content;
  final File? imageFile;

  const SaveArticleEdits({
    required this.original,
    required this.title,
    required this.content,
    this.imageFile,
  });

  @override
  List<Object?> get props => [original, title, content, imageFile];
}

class DeleteArticleRequested extends EditArticleEvent {
  final ArticleEntity article;

  const DeleteArticleRequested(this.article);

  @override
  List<Object?> get props => [article];
}

class ResetEditArticle extends EditArticleEvent {
  const ResetEditArticle();
}
