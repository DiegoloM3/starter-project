import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/article_draft_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/save_draft.dart';

class MockArticleDraftRepository extends Mock implements ArticleDraftRepository {}

void main() {
  late MockArticleDraftRepository drafts;

  setUpAll(() => registerFallbackValue(const ArticleDraftEntity()));

  setUp(() {
    drafts = MockArticleDraftRepository();
    when(() => drafts.saveDraft(any())).thenAnswer((_) async => const DataSuccess(null));
    when(() => drafts.deleteSavedDraft()).thenAnswer((_) async => const DataSuccess(null));
  });

  test('saves a draft with something written', () async {
    const draft = ArticleDraftEntity(content: 'A start');

    await SaveDraftUseCase(drafts)(params: draft);

    verify(() => drafts.saveDraft(draft)).called(1);
  });

  test('deletes the saved draft when everything was erased', () async {
    await SaveDraftUseCase(drafts)(params: const ArticleDraftEntity(title: '  ', author: 'Daily News Staff'));

    verify(() => drafts.deleteSavedDraft()).called(1);
    verifyNever(() => drafts.saveDraft(any()));
  });
}
