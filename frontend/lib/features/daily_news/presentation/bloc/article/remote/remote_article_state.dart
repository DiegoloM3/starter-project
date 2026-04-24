import 'package:equatable/equatable.dart';
<<<<<<< HEAD
import 'package:dio/dio.dart';
import '../../../../domain/entities/article.dart';

abstract class RemoteArticlesState extends Equatable {
  final List<ArticleEntity> ? articles;
  final DioError ? error;
  
  const RemoteArticlesState({this.articles,this.error});
  
  @override
  List<Object> get props => [articles!, error!];
=======
import 'package:news_app_clean_architecture/core/resources/app_error.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class RemoteArticlesState extends Equatable {
  const RemoteArticlesState();

  @override
  List<Object?> get props => [];
>>>>>>> fbce432 (Finish PR (project setup))
}

class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading();
}

<<<<<<< HEAD
class RemoteArticlesDone extends RemoteArticlesState {
  const RemoteArticlesDone(List<ArticleEntity> article) : super(articles: article);
}

class RemoteArticlesError extends RemoteArticlesState {
  const RemoteArticlesError(DioError error) : super(error: error);
}
=======
class RemoteArticlesEmpty extends RemoteArticlesState {
  const RemoteArticlesEmpty();
}

class RemoteArticlesDone extends RemoteArticlesState {
  final List<ArticleEntity> articles;
  const RemoteArticlesDone(this.articles);

  @override
  List<Object?> get props => [articles];
}

class RemoteArticlesError extends RemoteArticlesState {
  final AppError error;
  const RemoteArticlesError(this.error);

  @override
  List<Object?> get props => [error];
}
>>>>>>> fbce432 (Finish PR (project setup))
