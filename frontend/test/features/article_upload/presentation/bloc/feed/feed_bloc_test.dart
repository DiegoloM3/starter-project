import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_community_feed.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_event.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_fitness_articles.dart';
import 'package:news_app_clean_architecture/features/recommendations/domain/use_cases/recommend_for_user.dart';
import 'package:news_app_clean_architecture/features/search/domain/params/semantic_search_params.dart';
import 'package:news_app_clean_architecture/features/search/domain/use_cases/semantic_search.dart';
import 'package:news_app_clean_architecture/shared/feed/domain/entities/feed_item.dart';

class MockGetArticleUseCase extends Mock implements GetArticleUseCase {}

class MockGetFitnessArticlesUseCase extends Mock
    implements GetFitnessArticlesUseCase {}

class MockWatchCommunityFeedUseCase extends Mock
    implements WatchCommunityFeedUseCase {}

class MockSemanticSearchUseCase extends Mock implements SemanticSearchUseCase {}

class MockRecommendForUserUseCase extends Mock implements RecommendForUserUseCase {}

final _newsArticles = [
  const ArticleEntity(
    title: 'News One',
    description: 'A summary of news one',
    urlToImage: 'https://example.com/1.jpg',
    publishedAt: '2024-01-02T00:00:00Z',
    author: 'Reporter',
  ),
  const ArticleEntity(
    title: 'News Two',
    description: 'A summary of news two',
    urlToImage: 'https://example.com/2.jpg',
    publishedAt: '2024-01-01T00:00:00Z',
    author: 'Reporter Two',
  ),
];

JournalistArticleEntity _makeJournalistArticle({
  String id = 'j1',
  String title = 'Community One',
  String publishedAt = '2024-01-03T00:00:00Z',
  String userId = 'uid-abc',
}) =>
    JournalistArticleEntity(
      id: id,
      title: title,
      description: 'Description',
      content: 'Content',
      urlToImage: 'https://example.com/community.jpg',
      publishedAt: DateTime.parse(publishedAt),
      userId: userId,
      userDisplayName: 'Author',
      source: 'journalist',
      category: ArticleCategory.news,
      tags: [],
      language: 'en',
      readingTimeMinutes: 1,
      status: ArticleStatus.published,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
      viewCount: 0,
      favoriteCount: 0,
    );

void main() {
  late MockGetArticleUseCase getArticleUseCase;
  late MockGetFitnessArticlesUseCase getFitnessArticlesUseCase;
  late MockWatchCommunityFeedUseCase watchCommunityFeedUseCase;
  late MockSemanticSearchUseCase semanticSearchUseCase;
  late MockRecommendForUserUseCase recommendForUserUseCase;

  setUp(() {
    getArticleUseCase = MockGetArticleUseCase();
    getFitnessArticlesUseCase = MockGetFitnessArticlesUseCase();
    watchCommunityFeedUseCase = MockWatchCommunityFeedUseCase();
    semanticSearchUseCase = MockSemanticSearchUseCase();
    recommendForUserUseCase = MockRecommendForUserUseCase();
    when(() => getFitnessArticlesUseCase.call(params: any(named: 'params')))
        .thenAnswer((_) async => const DataSuccess(<ArticleEntity>[]));
    when(() => semanticSearchUseCase.call(params: any(named: 'params')))
        .thenAnswer((_) async => const DataSuccess(<String>[]));
    when(() => recommendForUserUseCase.call(params: any(named: 'params')))
        .thenAnswer((_) async => const DataSuccess(<ArticleEntity>[]));
  });

  FeedBloc buildBloc() => FeedBloc(
        getArticleUseCase,
        getFitnessArticlesUseCase,
        watchCommunityFeedUseCase,
        semanticSearchUseCase,
        recommendForUserUseCase,
      );

  group('FeedBloc', () {
    test('initial state has isLoading false and empty items', () {
      final bloc = buildBloc();
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.items, isEmpty);
      bloc.close();
    });

    blocTest<FeedBloc, FeedState>(
      'LoadFeedEvent fetches news and subscribes to community stream',
      build: () {
        when(() => getArticleUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => DataSuccess(_newsArticles));
        when(() => watchCommunityFeedUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) => Stream.value([_makeJournalistArticle()]));
        return buildBloc();
      },
      act: (b) => b.add(const LoadFeedEvent()),
      wait: const Duration(milliseconds: 50),
      verify: (b) {
        // After all events settle: isLoading is false and feed has both sources
        expect(b.state.isLoading, isFalse);
        expect(b.state.items.any((i) => i is NewsApiFeedItem), isTrue);
        expect(b.state.items.any((i) => i is JournalistFeedItem), isTrue);
      },
    );

    blocTest<FeedBloc, FeedState>(
      'FilterChangedEvent updates filter in state',
      build: buildBloc,
      act: (b) => b.add(const FilterChangedEvent(FeedFilter.community)),
      expect: () => [
        isA<FeedState>()
            .having((s) => s.filter, 'filter', FeedFilter.community),
      ],
    );

    blocTest<FeedBloc, FeedState>(
      'SearchQueryChangedEvent updates searchQuery in state',
      build: buildBloc,
      act: (b) => b.add(const SearchQueryChangedEvent('flutter')),
      wait: const Duration(milliseconds: 50),
      verify: (b) {
        expect(b.state.searchQuery, equals('flutter'));
      },
    );

    test('state.items returns sorted union when filter is all', () {
      // older news + newer community: community should sort first
      final communityItem = _makeJournalistArticle(
        publishedAt: '2024-03-01T00:00:00Z',
      );
      final newsItem = const ArticleEntity(
        title: 'Old News',
        publishedAt: '2024-01-01T00:00:00Z',
      );

      final state = FeedState(
        newsArticles: [newsItem],
        communityArticles: [communityItem],
        filter: FeedFilter.all,
      );

      final items = state.items;
      expect(items.length, 2);
      expect(items.first, isA<JournalistFeedItem>(),
          reason: 'community article (newer) should sort before news (older)');
    });

    test('state.items returns only news when filter is news', () {
      final state = FeedState(
        newsArticles: [const ArticleEntity(title: 'N1')],
        communityArticles: [_makeJournalistArticle()],
        filter: FeedFilter.news,
      );
      expect(state.items.every((i) => i is NewsApiFeedItem), isTrue);
    });

    test('state.items returns only community when filter is community', () {
      final state = FeedState(
        newsArticles: [const ArticleEntity(title: 'N1')],
        communityArticles: [_makeJournalistArticle()],
        filter: FeedFilter.community,
      );
      expect(state.items.every((i) => i is JournalistFeedItem), isTrue);
    });

    blocTest<FeedBloc, FeedState>(
      'LoadFeedEvent drops NewsAPI articles missing title, description, or thumbnail',
      build: () {
        final mixed = <ArticleEntity>[
          const ArticleEntity(
            title: 'Good Article',
            description: 'A complete description',
            urlToImage: 'https://example.com/good.jpg',
            publishedAt: '2024-01-01T00:00:00Z',
          ),
          const ArticleEntity(
            title: '[Removed]',
            description: '[Removed]',
            urlToImage: 'https://example.com/removed.jpg',
          ),
          const ArticleEntity(
            title: 'No image',
            description: 'desc',
            urlToImage: '',
          ),
          const ArticleEntity(
            title: 'Bad scheme',
            description: 'desc',
            urlToImage: 'not a url',
          ),
        ];
        when(() => getArticleUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => DataSuccess(mixed));
        when(() => watchCommunityFeedUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) => const Stream.empty());
        return buildBloc();
      },
      act: (b) => b.add(const LoadFeedEvent()),
      wait: const Duration(milliseconds: 50),
      verify: (b) {
        final newsItems =
            b.state.items.whereType<NewsApiFeedItem>().toList();
        expect(newsItems, hasLength(1));
        expect(newsItems.single.title, 'Good Article');
      },
    );

    blocTest<FeedBloc, FeedState>(
      'LoadMoreEvent on news filter appends next page and bumps newsPage',
      build: () {
        const page1 = <ArticleEntity>[
          ArticleEntity(
            title: 'Page 1 article',
            description: 'desc',
            urlToImage: 'https://example.com/1.jpg',
          ),
        ];
        const page2 = <ArticleEntity>[
          ArticleEntity(
            title: 'Page 2 article',
            description: 'desc',
            urlToImage: 'https://example.com/2.jpg',
          ),
        ];
        when(() => getArticleUseCase.call(params: any(named: 'params')))
            .thenAnswer((invocation) async {
          final p = invocation.namedArguments[#params];
          if (p != null && (p as dynamic).page == 2) {
            return const DataSuccess(page2);
          }
          return const DataSuccess(page1);
        });
        return buildBloc();
      },
      seed: () => const FeedState(
        filter: FeedFilter.news,
        newsArticles: [
          ArticleEntity(
            title: 'Page 1 article',
            description: 'desc',
            urlToImage: 'https://example.com/1.jpg',
          ),
        ],
        newsPage: 1,
      ),
      act: (b) => b.add(const LoadMoreEvent()),
      wait: const Duration(milliseconds: 50),
      verify: (b) {
        expect(b.state.newsPage, equals(2));
        expect(b.state.rawNewsArticles, hasLength(2));
        expect(b.state.isLoadingMore, isFalse);
      },
    );

    blocTest<FeedBloc, FeedState>(
      'LoadMoreEvent ignored while already loading more',
      build: buildBloc,
      seed: () => const FeedState(filter: FeedFilter.news, isLoadingMore: true),
      act: (b) => b.add(const LoadMoreEvent()),
      expect: () => [],
    );

    // --- Semantic search tests ---

    blocTest<FeedBloc, FeedState>(
      'SearchQueryChangedEvent with empty query clears searchResults',
      build: () => buildBloc(),
      seed: () => const FeedState(searchResults: ['old-id']),
      act: (b) => b.add(const SearchQueryChangedEvent('')),
      wait: const Duration(milliseconds: 50),
      verify: (b) {
        expect(b.state.searchQuery, equals(''));
        expect(b.state.searchResults, isNull);
      },
    );

    blocTest<FeedBloc, FeedState>(
      'SearchQueryChangedEvent debounces 300ms before executing',
      build: () {
        when(() => semanticSearchUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => const DataSuccess(['art-1']));
        return buildBloc();
      },
      act: (b) => b.add(const SearchQueryChangedEvent('marathon')),
      wait: const Duration(milliseconds: 400),
      verify: (b) {
        expect(b.state.searchResults, equals(['art-1']));
        verify(() => semanticSearchUseCase.call(params: any(named: 'params')))
            .called(1);
      },
    );

    blocTest<FeedBloc, FeedState>(
      'rapid SearchQueryChangedEvent fires the use case only once',
      build: () {
        when(() => semanticSearchUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => const DataSuccess(['art-final']));
        return buildBloc();
      },
      act: (b) async {
        b.add(const SearchQueryChangedEvent('m'));
        await Future.delayed(const Duration(milliseconds: 50));
        b.add(const SearchQueryChangedEvent('ma'));
        await Future.delayed(const Duration(milliseconds: 50));
        b.add(const SearchQueryChangedEvent('marathon'));
      },
      wait: const Duration(milliseconds: 500),
      verify: (b) {
        final captured =
            verify(() => semanticSearchUseCase.call(
                    params: captureAny(named: 'params')))
                .captured;
        expect(captured.length, equals(1));
        final params = captured.first as SemanticSearchParams;
        expect(params.query, equals('marathon'));
      },
    );

    blocTest<FeedBloc, FeedState>(
      'failed search emits error and clears searchResults',
      build: () {
        when(() => semanticSearchUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => const DataFailed(
                NetworkException(message: 'rate limit', code: 'rate-limit')));
        return buildBloc();
      },
      act: (b) => b.add(const SearchQueryChangedEvent('q')),
      wait: const Duration(milliseconds: 400),
      verify: (b) {
        expect(b.state.searchResults, isNull);
        expect(b.state.error, isA<NetworkException>());
      },
    );

    test('state.items returns matched community articles in searchResults order',
        () {
      final c1 = _makeJournalistArticle(
          id: 'c-1', publishedAt: '2024-01-01T00:00:00Z');
      final c2 = _makeJournalistArticle(
          id: 'c-2', publishedAt: '2024-03-01T00:00:00Z');
      final c3 = _makeJournalistArticle(
          id: 'c-3', publishedAt: '2024-02-01T00:00:00Z');

      final state = FeedState(
        communityArticles: [c1, c2, c3],
        searchResults: const ['c-2', 'c-1'], // semantic order, NOT publishedAt
      );

      final items = state.items;
      expect(items.length, 2);
      expect((items[0] as JournalistFeedItem).article.id, 'c-2');
      expect((items[1] as JournalistFeedItem).article.id, 'c-1');
    });

    test('state.items returns empty list when searchResults is empty', () {
      final state = FeedState(
        newsArticles: const [
          ArticleEntity(
            title: 'should-not-appear',
            description: 'desc',
            urlToImage: 'https://example.com/x.jpg',
          ),
        ],
        communityArticles: [_makeJournalistArticle()],
        searchResults: const [],
      );

      expect(state.items, isEmpty);
    });

    test('state.items reverts to filter-chip behavior when searchResults is null',
        () {
      final state = FeedState(
        newsArticles: const [
          ArticleEntity(
            title: 'news',
            description: 'desc',
            urlToImage: 'https://example.com/n.jpg',
          ),
        ],
        communityArticles: [_makeJournalistArticle()],
        filter: FeedFilter.all,
      );

      final items = state.items;
      expect(items.any((i) => i is NewsApiFeedItem), isTrue);
      expect(items.any((i) => i is JournalistFeedItem), isTrue);
    });

    blocTest<FeedBloc, FeedState>(
      'FilterChangedEvent(forYou) flips filter, sets loading, and dispatches recommend',
      setUp: () {
        when(() => recommendForUserUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => const DataSuccess(<ArticleEntity>[
                  ArticleEntity(
                    title: 'rec-1',
                    description: 'd',
                    urlToImage: 'https://e.com/i.jpg',
                  ),
                ]));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const FilterChangedEvent(FeedFilter.forYou)),
      skip: 0,
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.filter, FeedFilter.forYou);
        expect(bloc.state.recommendations, hasLength(1));
        expect(bloc.state.recommendations!.first.title, 'rec-1');
        expect(bloc.state.isLoadingRecommendations, isFalse);
      },
    );

    blocTest<FeedBloc, FeedState>(
      'FilterChangedEvent(forYou) failure surfaces error and clears loading',
      setUp: () {
        when(() => recommendForUserUseCase.call(params: any(named: 'params')))
            .thenAnswer(
          (_) async => DataFailed(NetworkException(message: 'boom')),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const FilterChangedEvent(FeedFilter.forYou)),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.isLoadingRecommendations, isFalse);
        expect(bloc.state.error, isA<NetworkException>());
      },
    );

    test('state.items returns recommendations in server order under forYou', () {
      const a = ArticleEntity(
        title: 'first',
        description: 'd',
        urlToImage: 'https://e.com/a.jpg',
        publishedAt: '2024-01-01T00:00:00Z',
      );
      const b = ArticleEntity(
        title: 'second',
        description: 'd',
        urlToImage: 'https://e.com/b.jpg',
        publishedAt: '2025-12-31T00:00:00Z', // newer date — but should NOT win
      );

      final state = FeedState(
        filter: FeedFilter.forYou,
        recommendations: const [a, b], // server-ranked: a first, b second
      );

      final items = state.items;
      expect(items.map((i) => (i as NewsApiFeedItem).article.title),
          ['first', 'second']);
    });
  });
}
