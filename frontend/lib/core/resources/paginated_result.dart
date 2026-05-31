/// Represents a paginated result from an API or data source.
///
/// This generic class wraps a list of items along with pagination metadata.
/// It is used by repositories to return paginated data to the domain layer.
class PaginatedResult<T> {
  /// The current page number (1-based).
  final int page;

  /// The number of items per page.
  final int pageSize;

  /// The total number of items available across all pages.
  final int totalResults;

  /// The list of items for the current page.
  final List<T> articles;

  const PaginatedResult({
    required this.page,
    required this.pageSize,
    required this.totalResults,
    required this.articles,
  });

  /// Determines if there are more pages available.
  bool get hasMore => page * pageSize < totalResults;
}
