import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';

abstract class CreateArticleState extends Equatable {
  const CreateArticleState();

  @override
  List<Object?> get props => [];
}

class CreateArticleIdle extends CreateArticleState {
  const CreateArticleIdle();
}

class CreateArticleSubmitting extends CreateArticleState {
  const CreateArticleSubmitting();
}

class CreateArticleSuccess extends CreateArticleState {
  final ArticleUploadEntity article;
  const CreateArticleSuccess(this.article);

  @override
  List<Object?> get props => [article];
}

class CreateArticleFailure extends CreateArticleState {
  final String reason;
  const CreateArticleFailure(this.reason);

  @override
  List<Object?> get props => [reason];
}
