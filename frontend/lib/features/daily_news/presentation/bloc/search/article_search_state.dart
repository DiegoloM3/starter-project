part of 'article_search_bloc.dart';

@immutable
sealed class ArticleSearchState {
  const ArticleSearchState();
}

class ArticleSearchShowingHistory extends ArticleSearchState {
  final List<String> history;
  const ArticleSearchShowingHistory({required this.history});
}

class ArticleSearchShowingResults extends ArticleSearchState {
  final String query;
  final List<ArticleEntity> results;
  const ArticleSearchShowingResults({required this.query, required this.results});
}