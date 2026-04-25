import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/shared/article/domain/entities/article.dart';

abstract class FirebaseArticlesState extends Equatable {
  const FirebaseArticlesState();

  @override
  List<Object?> get props => [];
}

class FirebaseArticlesInitial extends FirebaseArticlesState {
  const FirebaseArticlesInitial();
}

class FirebaseArticlesLoading extends FirebaseArticlesState {
  const FirebaseArticlesLoading();
}

class FirebaseArticlesDone extends FirebaseArticlesState {
  final List<ArticleEntity> articles;

  const FirebaseArticlesDone(this.articles);

  @override
  List<Object?> get props => [articles];
}

class FirebaseArticlesError extends FirebaseArticlesState {
  final String message;

  const FirebaseArticlesError(this.message);

  @override
  List<Object?> get props => [message];
}

class FirebaseArticleCreated extends FirebaseArticlesState {
  const FirebaseArticleCreated();
}
