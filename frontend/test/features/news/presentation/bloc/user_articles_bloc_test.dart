import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_user_articles.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/user/user_articles_bloc.dart';

import 'user_articles_bloc_test.mocks.dart';

@GenerateMocks([GetUserArticles, GetCurrentUserUseCase])
void main() {
  late MockGetUserArticles mockGetUserArticles;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  const tUser = UserEntity(
    id: 'user-123',
    email: 'john@example.com',
    displayName: 'John Doe',
  );

  const tArticles = [
    ArticleEntity(
      id: '1',
      authorDisplayName: 'John Doe',
      title: 'Test Title',
      urlToImage: 'https://example.com/image.jpg',
      publishedAt: '2026-09-27T00:00:00Z',
      content: 'Test Content',
      authorId: 'user-123',
    ),
  ];

  setUp(() {
    mockGetUserArticles = MockGetUserArticles();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
  });

  UserArticlesBloc buildBloc() =>
      UserArticlesBloc(mockGetUserArticles, mockGetCurrentUserUseCase);

  test('initial state is UserArticlesLoading', () {
    expect(buildBloc().state, isA<UserArticlesLoading>());
  });

  blocTest<UserArticlesBloc, UserArticlesState>(
    'emits [Loading, Done] when articles are loaded',
    build: () {
      when(mockGetCurrentUserUseCase.call())
          .thenAnswer((_) async => const DataSuccess(tUser));
      when(mockGetUserArticles.call(
              params: anyNamed('params')))
          .thenAnswer((_) async => const DataSuccess(tArticles));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadUserArticles()),
    expect: () => [
      const UserArticlesLoading(),
      const UserArticlesDone(tArticles),
    ],
    verify: (_) {
      verify(mockGetUserArticles.call(
        params: argThat(
          isA<GetUserArticlesParams>().having(
            (p) => p.userId,
            'userId',
            'user-123',
          ),
          named: 'params',
        ),
      )).called(1);
    },
  );

  blocTest<UserArticlesBloc, UserArticlesState>(
    'emits [Loading, Error] when no user is logged in',
    build: () {
      when(mockGetCurrentUserUseCase.call())
          .thenAnswer((_) async => const DataSuccess(null));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadUserArticles()),
    expect: () => [
      const UserArticlesLoading(),
      const UserArticlesError('Please log in to see your articles.'),
    ],
    verify: (_) {
      verifyZeroInteractions(mockGetUserArticles);
    },
  );

  blocTest<UserArticlesBloc, UserArticlesState>(
    'emits [Loading, Error] when the use case fails',
    build: () {
      when(mockGetCurrentUserUseCase.call())
          .thenAnswer((_) async => const DataSuccess(tUser));
      when(mockGetUserArticles.call(params: anyNamed('params'))).thenAnswer(
          (_) async => const DataGenericFailed('Failed to load articles'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadUserArticles()),
    expect: () => [
      const UserArticlesLoading(),
      const UserArticlesError('Failed to load articles'),
    ],
  );
}
