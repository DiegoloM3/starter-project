part of 'upload_user_article_bloc.dart';

@immutable
sealed class UploadUserArticleEvent extends Equatable {
  const UploadUserArticleEvent();

  @override
  List<Object?> get props => [];
}

class SubmitUserArticle extends UploadUserArticleEvent {
  final String title;
  final String content;
  final File image;

  const SubmitUserArticle(
      {required this.title, required this.content, required this.image});

  @override
  List<Object?> get props => [title, content, image];
}
