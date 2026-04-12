abstract class ArticlesListEvent {
  const ArticlesListEvent();
}

class FetchArticles extends ArticlesListEvent {
  const FetchArticles();
}

class DeleteArticleRequested extends ArticlesListEvent {
  final String articleId;
  const DeleteArticleRequested(this.articleId);
}

class SearchQueryChanged extends ArticlesListEvent {
  final String query;
  const SearchQueryChanged(this.query);
}

class LoadMoreArticles extends ArticlesListEvent {
  const LoadMoreArticles();
}
