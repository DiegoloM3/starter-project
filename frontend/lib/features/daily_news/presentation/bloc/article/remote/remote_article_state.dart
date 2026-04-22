import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class RemoteArticlesState extends Equatable {
  final List<ArticleEntity> ? articles;
  final DioException ? error;
  
  const RemoteArticlesState({this.articles,this.error});
  
  @override
  List<Object?> get props => [articles, error];
}

class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading();
}

class RemoteArticlesDone extends RemoteArticlesState {
  const RemoteArticlesDone(List<ArticleEntity> article) : super(articles: article);
}

class RemoteArticlesError extends RemoteArticlesState {
  const RemoteArticlesError(DioException error) : super(error: error);
}

// Write Operations States
class PostArticleLoading extends RemoteArticlesState {
  const PostArticleLoading();
}

class PostArticleSuccess extends RemoteArticlesState {
  const PostArticleSuccess();
}

class PostArticleError extends RemoteArticlesState {
  const PostArticleError(DioException error) : super(error: error);
}