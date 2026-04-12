import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/resources/error_type.dart';
import '../../../../domain/entities/article.dart';

abstract class RemoteArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final ErrorType? errorType;
  final bool hasMore;

  const RemoteArticlesState({
    this.articles,
    this.errorType,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [articles, errorType, hasMore];
}

class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading();
}

class RemoteArticlesDone extends RemoteArticlesState {
  const RemoteArticlesDone(List<ArticleEntity> articles, {super.hasMore})
      : super(articles: articles);
}

class RemoteArticlesCached extends RemoteArticlesState {
  const RemoteArticlesCached(List<ArticleEntity> articles)
      : super(articles: articles);
}

class RemoteArticlesLoadingMore extends RemoteArticlesState {
  const RemoteArticlesLoadingMore(List<ArticleEntity> articles)
      : super(articles: articles, hasMore: true);
}

class RemoteArticlesError extends RemoteArticlesState {
  const RemoteArticlesError(ErrorType errorType)
      : super(errorType: errorType);
}
