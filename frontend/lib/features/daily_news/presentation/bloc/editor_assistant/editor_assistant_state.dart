part of 'editor_assistant_cubit.dart';

enum EditorAssistantStatus { idle, loading, ready, failure }

class EditorAssistantState extends Equatable {
  final EditorAssistantStatus status;
  final EditorSuggestions? suggestions;
  final Failure? failure;

  const EditorAssistantState({
    this.status = EditorAssistantStatus.idle,
    this.suggestions,
    this.failure,
  });

  bool get isLoading => status == EditorAssistantStatus.loading;

  @override
  List<Object?> get props => [status, suggestions, failure];
}
