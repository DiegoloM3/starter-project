import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/saved_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/load_draft.dart';

import '../../../../helpers/mocks.dart';

void main() {
  test('returns the stored draft, or null when there is none', () async {
    final drafts = MockDraftRepository();
    const kept = SavedDraft(title: 'T');

    when(() => drafts.loadDraft()).thenAnswer((_) async => kept);
    expect(await LoadDraftUseCase(drafts)(const NoParams()), kept);

    when(() => drafts.loadDraft()).thenAnswer((_) async => null);
    expect(await LoadDraftUseCase(drafts)(const NoParams()), isNull);
  });
}
