import 'package:equatable/equatable.dart';

/// Something the reader searched for. Recent searches come most recent
/// first, so the domain doesn't need to know exactly when.
class SearchHistoryEntity extends Equatable {
  final String text;

  const SearchHistoryEntity({required this.text});

  @override
  List<Object?> get props => [text];
}
