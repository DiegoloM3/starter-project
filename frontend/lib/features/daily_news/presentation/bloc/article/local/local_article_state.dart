import 'package:equatable/equatable.dart';

import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class LocalArticlesState extends Equatable {
  const LocalArticlesState({this.articles});
  final List<ArticleEntity>? articles;

  @override
  List<Object> get props => [articles!];
}

class LocalArticlesLoading extends LocalArticlesState {
  const LocalArticlesLoading();
}

class LocalArticlesDone extends LocalArticlesState {
  const LocalArticlesDone(List<ArticleEntity> articles)
      : super(articles: articles);
}
