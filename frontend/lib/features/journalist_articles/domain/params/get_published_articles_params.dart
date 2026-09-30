import '../entities/published_article.dart';

/// One page of published articles, newest first.
class GetPublishedArticlesParams {
  static const int defaultPageSize = 20;

  /// The backend rejects list queries over this limit (see backend/firestore.rules).
  static const int maxPageSize = 50;

  final int pageSize;

  /// Last article of the previous page, or `null` for the first page.
  final PublishedArticleEntity? startAfter;

  const GetPublishedArticlesParams({this.pageSize = defaultPageSize, this.startAfter})
      : assert(pageSize > 0 && pageSize <= maxPageSize, 'pageSize must be between 1 and $maxPageSize');
}
