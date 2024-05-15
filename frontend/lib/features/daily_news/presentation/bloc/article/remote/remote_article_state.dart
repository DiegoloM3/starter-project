import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class RemoteArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final DioException? exception;
  final FirebaseException? firebaseException;

  const RemoteArticlesState(
      {this.articles, this.exception, this.firebaseException});

  @override
  List<Object> get props => [articles!, exception!];
}

class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading();
}

class RemoteArticlesDone extends RemoteArticlesState {
  const RemoteArticlesDone(List<ArticleEntity> article)
      : super(articles: article);
}

class RemoteArticlesError extends RemoteArticlesState {
  const RemoteArticlesError(DioException exception)
      : super(exception: exception);
}

class FireArticlesError extends RemoteArticlesState {
  const FireArticlesError(FirebaseException firebaseException)
      : super(firebaseException: firebaseException);
}
