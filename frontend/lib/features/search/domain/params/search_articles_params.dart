import 'package:equatable/equatable.dart';

class SearchArticlesParams extends Equatable {
  final String query;
  final int limit;

  const SearchArticlesParams({
    required this.query,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, limit];
}
