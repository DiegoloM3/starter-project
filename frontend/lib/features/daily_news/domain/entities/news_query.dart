import 'package:equatable/equatable.dart';

/// The sections of the news feed.
enum NewsCategory {
  top,
  business,
  technology,
  science,
  health,
  sports,
  entertainment,
}

/// Anything fetched a page at a time: the feed's sections and search.
abstract interface class PagedQuery {
  /// 1-based, like NewsAPI's own `page`.
  int get page;
  int get pageSize;
}

/// One page of one section of the feed.
class NewsQuery extends Equatable implements PagedQuery {
  final NewsCategory category;

  @override
  final int page;
  @override
  final int pageSize;

  const NewsQuery({
    this.category = NewsCategory.top,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [category, page, pageSize];
}

/// One page of results for a search.
class SearchQuery extends Equatable implements PagedQuery {
  final String text;

  /// Two-letter code ("en", "es"): results in the app's language.
  final String languageCode;

  @override
  final int page;
  @override
  final int pageSize;

  const SearchQuery({
    required this.text,
    required this.languageCode,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [text, languageCode, page, pageSize];
}
