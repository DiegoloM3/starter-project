part of 'upload_user_article_bloc.dart';

@immutable
sealed class UploadUserArticleState extends Equatable {
  const UploadUserArticleState();

  @override
  List<Object?> get props => [];
}

class UploadUserArticleInitial extends UploadUserArticleState {
  const UploadUserArticleInitial();
}

class UploadUserArticleLoading extends UploadUserArticleState {
  const UploadUserArticleLoading();
}

class UploadUserArticleSuccess extends UploadUserArticleState {
  const UploadUserArticleSuccess();
}

class UploadUserArticleError extends UploadUserArticleState {
  final String message;
  const UploadUserArticleError({required this.message});

  @override
  List<Object?> get props => [message];
}
