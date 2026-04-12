import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/resources/error_type.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class FirestoreArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final ErrorType? errorType;

  const FirestoreArticlesState({this.articles, this.errorType});

  @override
  List<Object?> get props => [articles, errorType];
}

class FirestoreArticlesLoading extends FirestoreArticlesState {
  const FirestoreArticlesLoading();
}

class FirestoreArticlesDone extends FirestoreArticlesState {
  const FirestoreArticlesDone(List<ArticleEntity> articles)
      : super(articles: articles);
}

class FirestoreArticlesError extends FirestoreArticlesState {
  const FirestoreArticlesError(ErrorType errorType)
      : super(errorType: errorType);
}
