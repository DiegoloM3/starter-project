import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class MyUploadedArticlesState extends Equatable {
  const MyUploadedArticlesState();

  @override
  List<Object?> get props => [];
}

class MyUploadedArticlesLoading extends MyUploadedArticlesState {
  const MyUploadedArticlesLoading();
}

class MyUploadedArticlesDone extends MyUploadedArticlesState {
  final List<ArticleEntity> articles;

  const MyUploadedArticlesDone(this.articles);

  @override
  List<Object?> get props => [articles];
}

class MyUploadedArticlesError extends MyUploadedArticlesState {
  final String message;

  const MyUploadedArticlesError(this.message);

  @override
  List<Object?> get props => [message];
}
