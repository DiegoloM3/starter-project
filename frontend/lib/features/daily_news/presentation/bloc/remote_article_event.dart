sealed class RemoteArticlesEvent {
  const RemoteArticlesEvent();
}

/// Event to load the first page of articles.
///
/// This event triggers a fresh load of articles from page 1, resetting
/// any previous pagination state.
final class GetArticles extends RemoteArticlesEvent {
  const GetArticles();
}

/// Event to load the next page of articles.
///
/// This event appends the next page of articles to the existing list,
/// enabling infinite scroll pagination.
final class LoadMoreArticles extends RemoteArticlesEvent {
  const LoadMoreArticles();
}
