part of 'article_search_bloc.dart';

@immutable
sealed class ArticleSearchEvent {
  const ArticleSearchEvent();
}

class LoadSearchHistory extends ArticleSearchEvent {
  const LoadSearchHistory();
}

class SearchQueryChanged extends ArticleSearchEvent {
  final String query;
  const SearchQueryChanged(this.query);
}

class SearchSubmitted extends ArticleSearchEvent {
  final String query;
  const SearchSubmitted(this.query);
}

class RemoveSearchHistoryItem extends ArticleSearchEvent {
  final String term;
  const RemoveSearchHistoryItem(this.term);
}