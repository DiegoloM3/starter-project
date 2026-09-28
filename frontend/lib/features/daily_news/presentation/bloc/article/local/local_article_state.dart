part of 'local_article_bloc.dart';

@immutable
sealed class LocalArticlesState extends Equatable {
  const LocalArticlesState();

  @override
  List<Object?> get props => [];
}

class LocalArticlesLoading extends LocalArticlesState {
  const LocalArticlesLoading();
}

class LocalArticlesDone extends LocalArticlesState {
  final List<ArticleEntity> articles;
  const LocalArticlesDone({required this.articles});

  @override
  List<Object?> get props => [articles];
}