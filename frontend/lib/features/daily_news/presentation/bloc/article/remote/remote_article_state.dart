import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/resources/error_type.dart';
import '../../../../domain/entities/article.dart';

abstract class RemoteArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final ErrorType? errorType;

  const RemoteArticlesState({this.articles, this.errorType});

  @override
  List<Object?> get props => [articles, errorType];
}

class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading();
}

class RemoteArticlesDone extends RemoteArticlesState {
  const RemoteArticlesDone(List<ArticleEntity> article)
      : super(articles: article);
}

class RemoteArticlesError extends RemoteArticlesState {
  const RemoteArticlesError(ErrorType errorType)
      : super(errorType: errorType);
}
