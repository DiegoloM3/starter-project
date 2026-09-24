import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/repository/journalist_article_repository_in_memory_impl.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_failures.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';

import '../../../../helpers/article_fixtures.dart';

void main() {
  late JournalistArticleRepositoryInMemoryImpl repository;

  final storedArticles = [
    publishableArticle(id: 'a-1', status: ArticleStatus.published).copyWith(
      title: 'The night bus driver',
      userId: 'journalist-1',
      publishedAt: DateTime(2026, 9, 18),
      updatedAt: DateTime(2026, 9, 20),
    ),
    publishableArticle(id: 'a-2').copyWith(
      title: 'Transit plan explained',
      userId: 'journalist-1',
      updatedAt: DateTime(2026, 9, 21),
    ),
    publishableArticle(id: 'a-3').copyWith(
      title: 'Someone else article',
      userId: 'journalist-2',
      updatedAt: DateTime(2026, 9, 22),
    ),
  ];

  setUp(() {
    repository = JournalistArticleRepositoryInMemoryImpl(
      initialArticles: storedArticles,
    );
  });

  test('returns only the articles of the author, most recent first', () async {
    final result = await repository.getUserArticles(userId: 'journalist-1');

    expect(result, isA<DataSuccess>());
    expect(
      result.data?.map((article) => article.id).toList(),
      ['a-2', 'a-1'],
    );
  });

  test('filters by status', () async {
    final result = await repository.getUserArticles(
      userId: 'journalist-1',
      status: ArticleStatus.published,
    );

    expect(result.data?.map((article) => article.id).toList(), ['a-1']);
  });

  test('filters by search query, ignoring case', () async {
    final result = await repository.getUserArticles(
      userId: 'journalist-1',
      searchQuery: '  TRANSIT ',
    );

    expect(result.data?.map((article) => article.id).toList(), ['a-2']);
  });

  test('creates an article with an identifier and timestamps', () async {
    const newArticle = JournalistArticleEntity(
      title: 'Fresh draft',
      author: 'Alex Rivera',
      userId: 'journalist-1',
    );

    final result = await repository.createArticle(newArticle);
    final created = result.data;

    expect(created?.isStored, isTrue);
    expect(created?.createdAt, isNotNull);
    expect(created?.updatedAt, isNotNull);
    expect(created?.publishedAt, isNull);

    final stored = await repository.getArticleById(created!.id!);
    expect(stored.data?.title, 'Fresh draft');
  });

  test('stamps the publication date when an article is born published',
      () async {
    final result = await repository.createArticle(
      publishableArticle(id: null, status: ArticleStatus.published),
    );

    expect(result.data?.publishedAt, isNotNull);
  });

  test('reports an unknown article instead of crashing', () async {
    final result = await repository.getArticleById('does-not-exist');

    expect(result, isA<DataFailed>());
    expect(result.error, isA<ArticleNotFoundException>());
  });

  test('updates a stored article and refreshes its update date', () async {
    final edited = storedArticles.first.copyWith(title: 'A better title');

    final result = await repository.updateArticle(edited);

    expect(result.data?.title, 'A better title');
    expect(
      result.data?.updatedAt?.isAfter(DateTime(2026, 9, 20)),
      isTrue,
    );
  });

  test('deletes a stored article', () async {
    final result = await repository.deleteArticle('a-1');
    final remaining = await repository.getUserArticles(
      userId: 'journalist-1',
    );

    expect(result, isA<DataSuccess>());
    expect(remaining.data?.map((article) => article.id).toList(), ['a-2']);
  });

  test('does not touch the list it was seeded with', () async {
    await repository.deleteArticle('a-1');

    expect(storedArticles, hasLength(3));
  });

  group('getPublishedArticles', () {
    test('returns only published articles, newest published first', () async {
      final result = await repository.getPublishedArticles();

      expect(result.data?.map((article) => article.id).toList(), ['a-1']);
    });

    test('filters by author', () async {
      final result = await repository.getPublishedArticles(
        authorId: 'journalist-2',
      );

      expect(result.data, isEmpty);
    });

    test('excludes the given article id', () async {
      final result = await repository.getPublishedArticles(
        excludeArticleId: 'a-1',
      );

      expect(result.data, isEmpty);
    });

    test('leaves out anything published before the window', () async {
      final result = await repository.getPublishedArticles(
        publishedAfter: DateTime(2026, 9, 19),
      );

      // a-1 went public on the 18th, a day before the window opens.
      expect(result.data, isEmpty);
    });

    test('keeps what was published inside the window', () async {
      final result = await repository.getPublishedArticles(
        publishedAfter: DateTime(2026, 9, 17),
      );

      expect(result.data?.map((a) => a.id).toList(), ['a-1']);
    });

    test('pages results after the given cursor', () async {
      final extraPublished = publishableArticle(
        id: 'a-4',
        status: ArticleStatus.published,
      ).copyWith(
        userId: 'journalist-1',
        publishedAt: DateTime(2026, 9, 10),
      );
      repository = JournalistArticleRepositoryInMemoryImpl(
        initialArticles: [...storedArticles, extraPublished],
      );

      final firstPage = await repository.getPublishedArticles(limit: 1);
      expect(firstPage.data?.map((a) => a.id).toList(), ['a-1']);

      final secondPage = await repository.getPublishedArticles(
        limit: 1,
        startAfterArticleId: firstPage.data!.first.id,
      );
      expect(secondPage.data?.map((a) => a.id).toList(), ['a-4']);
    });
  });

  group('incrementViewCount', () {
    test('increments the view count without touching updatedAt', () async {
      final before = await repository.getArticleById('a-1');
      final beforeUpdatedAt = before.data!.updatedAt;

      final result = await repository.incrementViewCount('a-1');
      final after = await repository.getArticleById('a-1');

      expect(result, isA<DataSuccess>());
      expect(after.data?.viewCount, 1);
      expect(after.data?.updatedAt, beforeUpdatedAt);
    });

    test('reports an unknown article instead of crashing', () async {
      final result = await repository.incrementViewCount('does-not-exist');

      expect(result, isA<DataFailed>());
      expect(result.error, isA<ArticleNotFoundException>());
    });
  });
}
