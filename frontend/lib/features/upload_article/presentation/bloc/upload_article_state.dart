import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/user_article.dart';

sealed class UploadArticleState extends Equatable {
  const UploadArticleState();

  @override
  List<Object?> get props => [];
}

class UploadArticleIdle extends UploadArticleState {
  const UploadArticleIdle();
}

class UploadArticleSubmitting extends UploadArticleState {
  const UploadArticleSubmitting();
}

class UploadArticleSuccess extends UploadArticleState {
  final UserArticleEntity article;
  const UploadArticleSuccess(this.article);

  @override
  List<Object?> get props => [article];
}

class UploadArticleFailure extends UploadArticleState {
  final String message;
  const UploadArticleFailure(this.message);

  @override
  List<Object?> get props => [message];
}
