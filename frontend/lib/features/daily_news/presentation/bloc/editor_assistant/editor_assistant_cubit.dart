import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/editor_suggestions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/suggest_article_edits.dart';

part 'editor_assistant_state.dart';

/// "Ask the editor" on the Publish screen: one request per tap, the answer
/// kept until the next one.
class EditorAssistantCubit extends Cubit<EditorAssistantState> {
  final SuggestArticleEditsUseCase _suggest;

  EditorAssistantCubit(this._suggest) : super(const EditorAssistantState());

  Future<void> ask(ArticleDraft draft) async {
    if (state.isLoading) return;
    emit(const EditorAssistantState(status: EditorAssistantStatus.loading));

    final result = await _suggest(draft);
    if (isClosed) return;
    emit(switch (result) {
      DataSuccess(:final data) =>
        EditorAssistantState(status: EditorAssistantStatus.ready, suggestions: data),
      DataFailed(:final failure) =>
        EditorAssistantState(status: EditorAssistantStatus.failure, failure: failure),
    });
  }

  /// Called when the sheet closes, which can be after the screen is gone.
  void dismiss() {
    if (isClosed) return;
    emit(const EditorAssistantState());
  }
}
