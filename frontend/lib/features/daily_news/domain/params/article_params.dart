/// Parameters for the get article use case and repository.
///
/// This class encapsulates pagination parameters (page and pageSize)
/// to be passed across the domain boundary.
class ArticleParams {
  /// The page number to fetch (1-based indexing). Defaults to 1.
  final int page;

  /// The number of articles per page. Defaults to 20, maximum is 100.
  final int pageSize;

  const ArticleParams({this.page = 1, this.pageSize = 20});
}
