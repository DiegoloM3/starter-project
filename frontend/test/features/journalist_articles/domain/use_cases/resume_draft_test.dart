import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/article_draft_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/author_signature_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/resume_draft.dart';

class MockArticleDraftRepository extends Mock implements ArticleDraftRepository {}

class MockAuthorSignatureRepository extends Mock implements AuthorSignatureRepository {}

const unfinishedDraft = ArticleDraftEntity(title: 'Half written', author: 'Local Desk');

void main() {
  late MockArticleDraftRepository drafts;
  late MockAuthorSignatureRepository signatures;
  late ResumeDraftUseCase resumeDraft;

  setUp(() {
    drafts = MockArticleDraftRepository();
    signatures = MockAuthorSignatureRepository();
    resumeDraft = ResumeDraftUseCase(drafts, signatures);
    when(() => signatures.getSavedAuthorName()).thenAnswer((_) async => const DataSuccess('Daily News Staff'));
  });

  void givenSavedDraft(DataState<ArticleDraftEntity?> result) {
    when(() => drafts.getSavedDraft()).thenAnswer((_) async => result);
  }

  test('continues the draft saved on the device', () async {
    givenSavedDraft(const DataSuccess(unfinishedDraft));

    expect((await resumeDraft()).data, unfinishedDraft);
  });

  test('starts a new draft signed like the previous article when none was saved', () async {
    givenSavedDraft(const DataSuccess(null));

    expect((await resumeDraft()).data, const ArticleDraftEntity(author: 'Daily News Staff'));
  });

  test('starts a new draft when the saved one is blank', () async {
    givenSavedDraft(const DataSuccess(ArticleDraftEntity(author: 'Old signature')));

    expect((await resumeDraft()).data, const ArticleDraftEntity(author: 'Daily News Staff'));
  });

  test('starts a new draft when the saved one cannot be read', () async {
    givenSavedDraft(const DataFailed(FormatException('corrupted')));

    expect((await resumeDraft()).data, const ArticleDraftEntity(author: 'Daily News Staff'));
  });

  test('starts unsigned when no article was published from this device', () async {
    givenSavedDraft(const DataSuccess(null));
    when(() => signatures.getSavedAuthorName()).thenAnswer((_) async => const DataSuccess(null));

    expect((await resumeDraft()).data, const ArticleDraftEntity());
  });
}
