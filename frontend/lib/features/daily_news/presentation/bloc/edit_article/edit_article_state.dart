import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class EditArticleState extends Equatable {
  const EditArticleState();

  @override
  List<Object?> get props => [];
}

class EditArticleInitial extends EditArticleState {
  const EditArticleInitial();
}

class EditArticleLoading extends EditArticleState {
  final double progress;

  const EditArticleLoading({this.progress = 0.0});

  @override
  List<Object?> get props => [progress];
}

class EditArticleSuccess extends EditArticleState {
  final ArticleEntity article;

  const EditArticleSuccess({required this.article});

  @override
  List<Object?> get props => [article];
}

class EditArticleFailure extends EditArticleState {
  final String error;

  const EditArticleFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class EditArticleValidationError extends EditArticleState {
  final Map<String, String> errors;

  const EditArticleValidationError({required this.errors});

  @override
  List<Object?> get props => [errors];
}
