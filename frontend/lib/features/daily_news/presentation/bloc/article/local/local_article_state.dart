import 'package:equatable/equatable.dart';
<<<<<<< HEAD

import '../../../../domain/entities/article.dart';

abstract class LocalArticlesState extends Equatable {
  final List<ArticleEntity> ? articles;

  const LocalArticlesState({this.articles});

  @override
  List<Object> get props => [articles!];
=======
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class LocalArticlesState extends Equatable {
  const LocalArticlesState();

  @override
  List<Object?> get props => [];
>>>>>>> fbce432 (Finish PR (project setup))
}

class LocalArticlesLoading extends LocalArticlesState {
  const LocalArticlesLoading();
}

class LocalArticlesDone extends LocalArticlesState {
<<<<<<< HEAD
  const LocalArticlesDone(List<ArticleEntity> articles) : super(articles: articles);
}
=======
  final List<ArticleEntity> articles;
  const LocalArticlesDone(this.articles);

  @override
  List<Object?> get props => [articles];
}
>>>>>>> fbce432 (Finish PR (project setup))
