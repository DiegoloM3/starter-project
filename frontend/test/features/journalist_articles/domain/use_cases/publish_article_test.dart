import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/invalid_article_draft_exception.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/article_draft_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/author_signature_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/published_article_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/publish_article.dart';

class MockPublishedArticleRepository extends Mock implements PublishedArticleRepository {}

class MockAuthorSignatureRepository extends Mock implements AuthorSignatureRepository {}

class MockArticleDraftRepository extends Mock implements ArticleDraftRepository {}

const validDraft = ArticleDraftEntity(
  title: 'Breaking News!',
  content: '## Subtitle\n\nThis is **breaking** news.',
  author: 'Daily News Staff',
  thumbnail: ArticleThumbnailEntity(localPath: '/gallery/photo.jpg', sizeInBytes: 1024),
);

void main() {
  late MockPublishedArticleRepository repository;
  late MockAuthorSignatureRepository signatures;
  late MockArticleDraftRepository drafts;
  late PublishArticleUseCase publishArticle;

  setUpAll(() => registerFallbackValue(const ArticleDraftEntity()));

  setUp(() {
    repository = MockPublishedArticleRepository();
    signatures = MockAuthorSignatureRepository();
    drafts = MockArticleDraftRepository();
    publishArticle = PublishArticleUseCase(repository, signatures, drafts);
    when(() => repository.publishArticle(any())).thenAnswer((_) async => const DataSuccess(null));
    when(() => signatures.saveAuthorName(any())).thenAnswer((_) async => const DataSuccess(null));
    when(() => drafts.deleteSavedDraft()).thenAnswer((_) async => const DataSuccess(null));
  });

  test('publishes a valid draft through the repository', () async {
    final result = await publishArticle(params: validDraft);

    expect(result, isA<DataSuccess<void>>());
    verify(() => repository.publishArticle(validDraft)).called(1);
  });

  test('publishes the trimmed text', () async {
    await publishArticle(params: validDraft.withTitle('  Breaking News!  ').withAuthor(' Daily News Staff '));

    verify(() => repository.publishArticle(validDraft)).called(1);
  });

  test('remembers the signature once the article is published', () async {
    await publishArticle(params: validDraft.withAuthor('  Daily News Staff '));

    verify(() => signatures.saveAuthorName('Daily News Staff')).called(1);
  });

  test('does not remember the signature when publishing fails', () async {
    when(() => repository.publishArticle(any())).thenAnswer((_) async => DataFailed(Exception('offline')));

    await publishArticle(params: validDraft);

    verifyNever(() => signatures.saveAuthorName(any()));
  });

  test('deletes the saved draft once the article is published', () async {
    await publishArticle(params: validDraft);

    verify(() => drafts.deleteSavedDraft()).called(1);
  });

  test('keeps the saved draft when publishing fails', () async {
    when(() => repository.publishArticle(any())).thenAnswer((_) async => DataFailed(Exception('offline')));

    await publishArticle(params: validDraft);

    verifyNever(() => drafts.deleteSavedDraft());
  });

  test('is still a success when the device cannot be updated', () async {
    when(() => drafts.deleteSavedDraft()).thenAnswer((_) async => DataFailed(Exception('disk full')));

    expect(await publishArticle(params: validDraft), isA<DataSuccess<void>>());
  });

  test('is still a success when the signature cannot be remembered', () async {
    when(() => signatures.saveAuthorName(any())).thenAnswer((_) async => DataFailed(Exception('disk full')));

    final result = await publishArticle(params: validDraft);

    expect(result, isA<DataSuccess<void>>());
  });

  test('returns the repository failure', () async {
    final error = Exception('offline');
    when(() => repository.publishArticle(any())).thenAnswer((_) async => DataFailed(error));

    final result = await publishArticle(params: validDraft);

    expect(result.error, same(error));
  });

  test('rejects an invalid draft with every error and never reaches the repository', () async {
    final result = await publishArticle(params: const ArticleDraftEntity(title: 'Only a title'));

    expect((result.error! as InvalidArticleDraftException).errors, {
      ArticleDraftError.contentEmpty,
      ArticleDraftError.authorEmpty,
      ArticleDraftError.thumbnailMissing,
    });
    verifyNever(() => repository.publishArticle(any()));
  });

  test('treats a missing draft as an empty one', () async {
    final result = await publishArticle();

    expect((result.error! as InvalidArticleDraftException).errors, contains(ArticleDraftError.titleEmpty));
  });
}
