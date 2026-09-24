import 'package:equatable/equatable.dart';

import '../../../../domain/entities/article.dart';
import '../../../../domain/entities/news_category.dart';

abstract class RemoteArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final Object? error;

  /// The section being shown. It is carried by every state, including the
  /// loading one, so the filter stays on the chip that was tapped instead of
  /// jumping back while the request is in flight.
  final NewsCategory category;

  const RemoteArticlesState({
    this.articles,
    this.error,
    this.category = NewsCategory.general,
  });

  @override
  List<Object?> get props => [articles, error, category];
}

class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading({super.category});
}

class RemoteArticlesDone extends RemoteArticlesState {
  const RemoteArticlesDone(List<ArticleEntity> articles, {super.category})
      : super(articles: articles);
}

class RemoteArticlesError extends RemoteArticlesState {
  const RemoteArticlesError(Object error, {super.category})
      : super(error: error);
}
