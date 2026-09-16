part of 'search_cubit.dart';

enum SearchStatus { idle, loading, results, failure }

class SearchState extends Equatable {
  final String query;
  final SearchStatus status;
  final List<ArticleEntity> results;

  /// Most recent first, without duplicates.
  final List<String> recent;
  final Failure? failure;

  const SearchState({
    this.query = '',
    this.status = SearchStatus.idle,
    this.results = const [],
    this.recent = const [],
    this.failure,
  });

  bool get hasNoResults => status == SearchStatus.results && results.isEmpty;

  SearchState copyWith({
    String? query,
    SearchStatus? status,
    List<ArticleEntity>? results,
    List<String>? recent,
    Failure? failure,
  }) {
    return SearchState(
      query: query ?? this.query,
      status: status ?? this.status,
      results: results ?? this.results,
      recent: recent ?? this.recent,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [query, status, results, recent, failure];
}
