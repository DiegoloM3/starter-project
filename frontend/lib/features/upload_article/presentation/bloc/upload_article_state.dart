import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

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

class UploadArticleSuccess extends UploadArticleState {
  final ArticleEntity article;

  const UploadArticleSuccess(this.article);

  @override
  List<Object?> get props => [article];
}

class UploadArticleError extends UploadArticleState {
  final String message;

  const UploadArticleError(this.message);

  @override
  List<Object?> get props => [message];
}
