import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/editor_suggestions.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/editor_assistant/editor_assistant_cubit.dart';

import '../../../../../helpers/fixtures.dart';
import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  setUpAll(() => registerFallbackValue(buildDraft()));

  late MockSuggestArticleEditsUseCase suggest;
  late EditorAssistantCubit cubit;
  const suggestions = EditorSuggestions(headlines: ['A'], summary: 'S');

  setUp(() {
    suggest = MockSuggestArticleEditsUseCase();
    cubit = EditorAssistantCubit(suggest);
  });
  tearDown(() => cubit.close());

  test('ask goes loading then ready, dismiss resets', () async {
    when(() => suggest(any())).thenAnswer((_) async => const DataSuccess(suggestions));
    final statuses = <EditorAssistantStatus>[];
    final sub = cubit.stream.listen((s) => statuses.add(s.status));

    await cubit.ask(buildDraft());
    await flush();
    await sub.cancel();

    expect(statuses, [EditorAssistantStatus.loading, EditorAssistantStatus.ready]);
    expect(cubit.state.suggestions, suggestions);

    cubit.dismiss();
    expect(cubit.state, const EditorAssistantState());
  });

  test('a failure is kept for the sheet to show', () async {
    when(() => suggest(any())).thenAnswer((_) async => const DataFailed(Failure.network()));

    await cubit.ask(buildDraft());

    expect(cubit.state.status, EditorAssistantStatus.failure);
    expect(cubit.state.failure, const Failure.network());
  });

  test('dismiss after the cubit is closed is a no-op', () async {
    await cubit.close();

    expect(cubit.dismiss, returnsNormally);
  });
}
