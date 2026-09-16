import 'package:equatable/equatable.dart';

/// What the desk editor proposes for a draft: alternative headlines and a
/// teaser. The journalist picks; nothing is
/// applied without a tap.
class EditorSuggestions extends Equatable {
  final List<String> headlines;
  final String summary;

  const EditorSuggestions({required this.headlines, required this.summary});

  bool get hasSummary => summary.trim().isNotEmpty;

  @override
  List<Object?> get props => [headlines, summary];
}
