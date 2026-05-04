import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/toggle_favorite_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/toggle_favorite.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_favorite_ids.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/favorites/favorites_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/favorites/favorites_event.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/favorites/favorites_state.dart';

class MockToggleFavoriteUseCase extends Mock implements ToggleFavoriteUseCase {}

class MockWatchFavoriteIdsUseCase extends Mock
    implements WatchFavoriteIdsUseCase {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockToggleFavoriteUseCase toggleFavoriteUseCase;
  late MockWatchFavoriteIdsUseCase watchFavoriteIdsUseCase;
  late MockFirebaseAuth firebaseAuth;
  late MockUser mockUser;

  setUp(() {
    toggleFavoriteUseCase = MockToggleFavoriteUseCase();
    watchFavoriteIdsUseCase = MockWatchFavoriteIdsUseCase();
    firebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    registerFallbackValue(
        const ToggleFavoriteParams(articleId: '', currentlyFavorited: false));
  });

  FavoritesBloc buildBloc() => FavoritesBloc(
        watchFavoriteIdsUseCase,
        toggleFavoriteUseCase,
        firebaseAuth,
      );

  group('FavoritesBloc', () {
    test('initial state has empty favoriteIds', () {
      final bloc = buildBloc();
      expect(bloc.state.favoriteIds, isEmpty);
      bloc.close();
    });

    blocTest<FavoritesBloc, FavoritesState>(
      'LoadFavoritesEvent subscribes to stream and emits favorite ids',
      build: () {
        when(() => firebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('uid-me');
        when(() => watchFavoriteIdsUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) => Stream.value(['art1', 'art2']));
        return buildBloc();
      },
      act: (b) => b.add(const LoadFavoritesEvent()),
      wait: const Duration(milliseconds: 50),
      verify: (b) {
        expect(b.state.favoriteIds, {'art1', 'art2'});
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'ToggleFavoriteEvent adds article optimistically then confirms on success',
      build: () {
        when(() => firebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('uid-me');
        when(() => toggleFavoriteUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => const DataSuccess(null));
        return buildBloc();
      },
      seed: () => const FavoritesState(favoriteIds: {}),
      act: (b) => b.add(const ToggleFavoriteEvent('art1')),
      expect: () => [
        isA<FavoritesState>().having(
          (s) => s.favoriteIds.contains('art1'),
          'art1 optimistically added',
          true,
        ),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'ToggleFavoriteEvent removes article optimistically then confirms on success',
      build: () {
        when(() => firebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('uid-me');
        when(() => toggleFavoriteUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => const DataSuccess(null));
        return buildBloc();
      },
      seed: () => const FavoritesState(favoriteIds: {'art1'}),
      act: (b) => b.add(const ToggleFavoriteEvent('art1')),
      expect: () => [
        isA<FavoritesState>().having(
          (s) => s.favoriteIds.contains('art1'),
          'art1 optimistically removed',
          false,
        ),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      // Optimistic add fails: prevIds (without art1) is restored with error
      'ToggleFavoriteEvent rolls back optimistic add on failure',
      build: () {
        when(() => firebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('uid-me');
        when(() => toggleFavoriteUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => DataFailed(
                  const FirestoreException(message: 'batch write failed'),
                ));
        return buildBloc();
      },
      seed: () => const FavoritesState(favoriteIds: {}),
      act: (b) => b.add(const ToggleFavoriteEvent('art1')),
      expect: () => [
        isA<FavoritesState>().having(
          (s) => s.favoriteIds.contains('art1'),
          'art1 optimistically added',
          true,
        ),
        isA<FavoritesState>()
            .having(
              (s) => s.favoriteIds.contains('art1'),
              'art1 rolled back',
              false,
            )
            .having((s) => s.error, 'error', isA<FirestoreException>()),
      ],
    );
  });
}
