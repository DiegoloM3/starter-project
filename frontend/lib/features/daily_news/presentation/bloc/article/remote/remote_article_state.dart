import 'package:equatable/equatable.dart';
import '../../../../domain/entities/article.dart';

abstract class RemoteArticlesState extends Equatable {
  final List<ArticleEntity> ? articles;
  final Exception ? error;
  
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
  const RemoteArticlesError(Exception error) : super(error: error);
}