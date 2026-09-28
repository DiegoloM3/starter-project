part of 'create_article_bloc.dart';

/// Events consumed by [CreateArticleBloc].
abstract class CreateArticleEvent extends Equatable {
  const CreateArticleEvent();

  @override
  List<Object?> get props => [];
}

class PublishArticle extends CreateArticleEvent {
  final String title;
  final String content;
  final File? imageFile;

  const PublishArticle({
    required this.title,
    required this.content,
    this.imageFile,
  });

  @override
  List<Object?> get props => [title, content, imageFile];
}

class ResetCreateArticle extends CreateArticleEvent {
  const ResetCreateArticle();
}
