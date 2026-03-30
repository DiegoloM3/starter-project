import 'package:equatable/equatable.dart';

abstract class UploadArticleState extends Equatable {
  const UploadArticleState();

  @override
  List<Object?> get props => [];
}

class UploadArticleInitial extends UploadArticleState {
  const UploadArticleInitial();
}

class UploadArticleLoading extends UploadArticleState {
  const UploadArticleLoading();
}

class UploadArticleDone extends UploadArticleState {
  const UploadArticleDone();
}

class UploadArticleError extends UploadArticleState {
  final String error;
  const UploadArticleError(this.error);

  @override
  List<Object?> get props => [error];
}
