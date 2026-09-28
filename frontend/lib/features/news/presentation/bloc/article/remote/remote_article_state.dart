import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';

/// UI states emitted by [RemoteArticlesBloc].
abstract class RemoteArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final String? errorMessage;

  const RemoteArticlesState({this.articles, this.errorMessage});

  @override
  List<Object> get props => [
        if (articles != null) articles!,
        if (errorMessage != null) errorMessage!,
      ];
}

class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading();
}

class RemoteArticlesDone extends RemoteArticlesState {
  const RemoteArticlesDone(List<ArticleEntity> article) : super(articles: article);
}

class RemoteArticlesError extends RemoteArticlesState {
  const RemoteArticlesError(String errorMessage)
      : super(errorMessage: errorMessage);
}
