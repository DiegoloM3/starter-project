import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/article_draft_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/discard_draft.dart';

class MockArticleDraftRepository extends Mock implements ArticleDraftRepository {}

void main() {
  test('deletes the saved draft', () async {
    final drafts = MockArticleDraftRepository();
    when(() => drafts.deleteSavedDraft()).thenAnswer((_) async => const DataSuccess(null));

    await DiscardDraftUseCase(drafts)();

    verify(() => drafts.deleteSavedDraft()).called(1);
  });
}
