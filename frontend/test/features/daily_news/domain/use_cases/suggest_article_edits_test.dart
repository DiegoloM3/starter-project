import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/editor_suggestions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/suggest_article_edits.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(buildDraft()));

  late MockArticleAssistantRepository assistant;
  const suggestions = EditorSuggestions(headlines: ['A'], summary: 'S');
  final longEnough = List.filled(SuggestArticleEditsUseCase.minimumWords, 'word').join(' ');

  setUp(() => assistant = MockArticleAssistantRepository());

  test('refuses a draft too short to judge without calling the editor', () async {
    final result = await SuggestArticleEditsUseCase(assistant)(buildDraft(content: 'Too short.'));

    expect(result.failureOrNull?.type, FailureType.validation);
    verifyNever(() => assistant.suggest(any()));
  });

  test('forwards a long enough draft', () async {
    when(() => assistant.suggest(any())).thenAnswer((_) async => const DataSuccess(suggestions));

    final result = await SuggestArticleEditsUseCase(assistant)(buildDraft(content: longEnough));

    expect(result.dataOrNull, suggestions);
  });

  test('counts words, not characters', () {
    expect(SuggestArticleEditsUseCase.wordCount('one  two\nthree'), 3);
    expect(SuggestArticleEditsUseCase.wordCount('   '), 0);
  });
}
