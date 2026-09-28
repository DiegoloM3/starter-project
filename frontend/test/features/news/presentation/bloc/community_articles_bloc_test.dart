import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_all_user_articles.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/community/community_articles_bloc.dart';

import 'community_articles_bloc_test.mocks.dart';

@GenerateMocks([GetAllUserArticles])
void main() {
  late MockGetAllUserArticles mockGetAllUserArticles;

  const tArticles = [
    ArticleEntity(
      id: '1',
      authorDisplayName: 'Jane Doe',
      title: 'Community Post',
      urlToImage: 'https://example.com/community.jpg',
      publishedAt: '2026-09-27T00:00:00Z',
      content: 'Community content',
      authorId: 'user-456',
    ),
  ];

  setUp(() {
    mockGetAllUserArticles = MockGetAllUserArticles();
  });

  CommunityArticlesBloc buildBloc() =>
      CommunityArticlesBloc(mockGetAllUserArticles);

  test('initial state is CommunityArticlesLoading', () {
    expect(buildBloc().state, isA<CommunityArticlesLoading>());
  });

  blocTest<CommunityArticlesBloc, CommunityArticlesState>(
    'emits [Loading, Done] when community articles are loaded',
    build: () {
      when(mockGetAllUserArticles.call())
          .thenAnswer((_) async => const DataSuccess(tArticles));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadCommunityArticles()),
    expect: () => [
      const CommunityArticlesLoading(),
      const CommunityArticlesDone(tArticles),
    ],
    verify: (_) {
      verify(mockGetAllUserArticles.call()).called(1);
    },
  );

  blocTest<CommunityArticlesBloc, CommunityArticlesState>(
    'emits [Loading, Done] with an empty list when nobody wrote yet',
    build: () {
      when(mockGetAllUserArticles.call()).thenAnswer(
          (_) async => const DataSuccess(<ArticleEntity>[]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadCommunityArticles()),
    expect: () => [
      const CommunityArticlesLoading(),
      const CommunityArticlesDone(<ArticleEntity>[]),
    ],
  );

  blocTest<CommunityArticlesBloc, CommunityArticlesState>(
    'emits [Loading, Error] when the use case fails',
    build: () {
      when(mockGetAllUserArticles.call()).thenAnswer(
          (_) async => const DataGenericFailed('Failed to load articles'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadCommunityArticles()),
    expect: () => [
      const CommunityArticlesLoading(),
      const CommunityArticlesError('Failed to load articles'),
    ],
  );
}
