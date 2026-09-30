import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/local/article_draft_local_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/repository/article_draft_repository_impl.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';

class MockArticleDraftLocalDataSource extends Mock implements ArticleDraftLocalDataSource {}

const draft = ArticleDraftEntity(title: 'Half written');

void main() {
  late MockArticleDraftLocalDataSource dataSource;
  late ArticleDraftRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(draft));

  setUp(() {
    dataSource = MockArticleDraftLocalDataSource();
    repository = ArticleDraftRepositoryImpl(dataSource);
  });

  test('returns the saved draft as an entity', () async {
    when(() => dataSource.readDraft()).thenReturn(const ArticleDraftModel(title: 'Half written'));

    final result = await repository.getSavedDraft();

    expect(result.data, draft);
    expect(result.data, isNot(isA<ArticleDraftModel>()));
  });

  test('fails when the saved draft is corrupted', () async {
    when(() => dataSource.readDraft()).thenThrow(const FormatException('corrupted'));

    expect(await repository.getSavedDraft(), isA<DataFailed<ArticleDraftEntity?>>());
  });

  test('saves the draft', () async {
    when(() => dataSource.writeDraft(any())).thenAnswer((_) async {});

    expect(await repository.saveDraft(draft), isA<DataSuccess<void>>());
    verify(() => dataSource.writeDraft(draft)).called(1);
  });

  test('fails when the device cannot store the draft', () async {
    final error = Exception('disk full');
    when(() => dataSource.writeDraft(any())).thenThrow(error);

    expect((await repository.saveDraft(draft)).error, same(error));
  });

  test('deletes the saved draft', () async {
    when(() => dataSource.deleteDraft()).thenAnswer((_) async {});

    expect(await repository.deleteSavedDraft(), isA<DataSuccess<void>>());
  });
}
