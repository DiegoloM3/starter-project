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
  final double progress;

  const UploadArticleLoading({this.progress = 0.0});

  @override
  List<Object?> get props => [progress];
}

class UploadArticleSuccess extends UploadArticleState {
  final ArticleEntity article;

  const UploadArticleSuccess({required this.article});

  @override
  List<Object?> get props => [article];
}

class UploadArticleFailure extends UploadArticleState {
  final String error;

  const UploadArticleFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class UploadArticleValidationError extends UploadArticleState {
  final Map<String, String> errors;

  const UploadArticleValidationError({required this.errors});

  @override
  List<Object?> get props => [errors];
}
