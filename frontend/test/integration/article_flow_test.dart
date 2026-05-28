import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/add_comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_comments.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_published_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_thumbnail.dart';

import '../helpers/mock_classes.dart';
import '../helpers/register_fallback_values.dart';
import '../helpers/test_fixtures.dart';

/// Integration test: exercises the full happy path using mocked repositories
/// to verify use case orchestration works end-to-end.
///
/// Flow: create draft → upload thumbnail → publish → read feed →
///       add comment → read comments → soft-delete article
void main() {
  late MockArticleRepository mockArticleRepo;
  late MockCommentRepository mockCommentRepo;

  late CreateArticleUseCase createArticle;
  late UploadThumbnailUseCase uploadThumbnail;
  late UpdateArticleUseCase updateArticle;
  late GetPublishedArticlesUseCase getPublished;
  late AddCommentUseCase addComment;
  late GetCommentsUseCase getComments;
  late DeleteArticleUseCase deleteArticle;

  setUpAll(() => registerTestFallbackValues());

  setUp(() {
    mockArticleRepo = MockArticleRepository();
    mockCommentRepo = MockCommentRepository();

    createArticle = CreateArticleUseCase(mockArticleRepo);
    uploadThumbnail = UploadThumbnailUseCase(mockArticleRepo);
    updateArticle = UpdateArticleUseCase(mockArticleRepo);
    getPublished = GetPublishedArticlesUseCase(mockArticleRepo);
    addComment = AddCommentUseCase(mockCommentRepo);
    getComments = GetCommentsUseCase(mockCommentRepo);
    deleteArticle = DeleteArticleUseCase(mockArticleRepo);
  });

  test('full article lifecycle: create → upload → publish → comment → delete',
      () async {
    // -- Step 1: Create article as draft --
    final draftArticle = testArticle(
      id: 'new-article-id',
      status: ArticleStatus.draft,
    );
    when(() => mockArticleRepo.createArticle(any()))
        .thenAnswer((_) async => DataSuccess(draftArticle));

    final createResult = await createArticle(
      params: testArticle(status: ArticleStatus.draft),
    );

    expect(createResult, isA<DataSuccess<ArticleEntity>>());
    expect(createResult.data!.id, 'new-article-id');
    expect(createResult.data!.status, ArticleStatus.draft);

    // -- Step 2: Upload thumbnail --
    when(() => mockArticleRepo.uploadThumbnail(
          articleId: any(named: 'articleId'),
          filePath: any(named: 'filePath'),
        )).thenAnswer((_) async => const DataSuccess(tThumbnailUrl));

    final uploadResult = await uploadThumbnail(
      params: const UploadThumbnailParams(
        articleId: 'new-article-id',
        filePath: tFilePath,
      ),
    );

    expect(uploadResult, isA<DataSuccess<String>>());
    expect(uploadResult.data, tThumbnailUrl);

    // -- Step 3: Publish article (status transition draft → published) --
    final publishedArticle = testArticle(
      id: 'new-article-id',
      status: ArticleStatus.published,
      thumbnailUrl: tThumbnailUrl,
    );
    when(() => mockArticleRepo.updateArticle(any()))
        .thenAnswer((_) async => DataSuccess(publishedArticle));

    expect(
      ArticleStatus.isValidTransition(
        ArticleStatus.draft,
        ArticleStatus.published,
      ),
      isTrue,
    );

    final publishResult = await updateArticle(
      params: draftArticle.copyWith(status: ArticleStatus.published),
    );

    expect(publishResult, isA<DataSuccess<ArticleEntity>>());
    expect(publishResult.data!.status, ArticleStatus.published);

    // -- Step 4: Read published articles (verify article in feed) --
    when(() => mockArticleRepo.getPublishedArticles())
        .thenAnswer((_) => Stream.value(DataSuccess([publishedArticle])));

    final feedStream = getPublished();
    final feedData = await feedStream.first;

    expect(feedData, isA<DataSuccess>());
    expect(feedData.data!.length, 1);
    expect(feedData.data!.first.id, 'new-article-id');

    // -- Step 5: Add comment --
    final comment = testComment(
      articleId: 'new-article-id',
      content: 'Great article!',
    );
    when(() => mockCommentRepo.addComment(any()))
        .thenAnswer((_) async => DataSuccess(comment));

    final commentResult = await addComment(params: comment);

    expect(commentResult, isA<DataSuccess<CommentEntity>>());
    expect(commentResult.data!.content, 'Great article!');

    // -- Step 6: Read comments --
    when(() => mockCommentRepo.getComments(any()))
        .thenAnswer((_) => Stream.value(DataSuccess([comment])));

    final commentsStream = getComments(params: 'new-article-id');
    final commentsData = await commentsStream.first;

    expect(commentsData, isA<DataSuccess>());
    expect(commentsData.data!.length, 1);
    expect(commentsData.data!.first.content, 'Great article!');

    // -- Step 7: Soft-delete article --
    when(() => mockArticleRepo.deleteArticle(any()))
        .thenAnswer((_) async => const DataSuccess(null));

    final deleteResult = await deleteArticle(params: 'new-article-id');

    expect(deleteResult, isA<DataSuccess>());
    verify(() => mockArticleRepo.deleteArticle('new-article-id')).called(1);
  });
}
