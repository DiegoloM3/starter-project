import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/saved_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_draft.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockDraftRepository drafts;

  setUp(() {
    drafts = MockDraftRepository();
    when(() => drafts.saveDraft(any())).thenAnswer((_) async => const DataSuccess(null));
    when(() => drafts.clearDraft()).thenAnswer((_) async => const DataSuccess(null));
  });
  setUpAll(() => registerFallbackValue(const SavedDraft()));

  test('a draft with content is stored', () async {
    const draft = SavedDraft(title: 'T');

    await SaveDraftUseCase(drafts)(draft);

    verify(() => drafts.saveDraft(draft)).called(1);
    verifyNever(() => drafts.clearDraft());
  });

  test('an empty draft clears what was stored instead', () async {
    await SaveDraftUseCase(drafts)(const SavedDraft(title: '  '));

    verify(() => drafts.clearDraft()).called(1);
    verifyNever(() => drafts.saveDraft(any()));
  });
}
