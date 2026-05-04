import 'package:equatable/equatable.dart';

class SemanticSearchParams extends Equatable {
  final String query;
  final int limit;

  const SemanticSearchParams({required this.query, this.limit = 10});

  @override
  List<Object?> get props => [query, limit];
}
