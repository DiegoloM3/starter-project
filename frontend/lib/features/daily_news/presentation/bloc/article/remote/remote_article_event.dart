abstract class RemoteArticlesEvent {
  const RemoteArticlesEvent();
}

class GetArticles extends RemoteArticlesEvent {
  const GetArticles();
}

class LoadMoreArticles extends RemoteArticlesEvent {
  const LoadMoreArticles();
}
