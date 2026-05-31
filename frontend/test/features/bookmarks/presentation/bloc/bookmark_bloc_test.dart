import 'package:bloc_test/bloc_test.dart';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/article_source.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/bookmark_entity.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/usecases/add_bookmark.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/usecases/get_bookmarks.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/usecases/remove_bookmark.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_bloc.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_event.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_state.dart';

import 'bookmark_bloc_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<WatchBookmarksUseCase>(),
  MockSpec<AddBookmarkUseCase>(),
  MockSpec<RemoveBookmarkUseCase>(),
])
void main() {
  group('BookmarkBloc', () {
    late MockWatchBookmarksUseCase watchBookmarksUseCase;
    late MockAddBookmarkUseCase addBookmarkUseCase;
    late MockRemoveBookmarkUseCase removeBookmarkUseCase;
    late StreamController<List<BookmarkEntity>> bookmarksController;

    const bookmark = BookmarkEntity(
      sourceId: 'id-1',
      source: ArticleSource.api,
      title: 'Top story',
    );

    setUp(() {
      bookmarksController = StreamController<List<BookmarkEntity>>.broadcast();
      watchBookmarksUseCase = MockWatchBookmarksUseCase();
      addBookmarkUseCase = MockAddBookmarkUseCase();
      removeBookmarkUseCase = MockRemoveBookmarkUseCase();

      when(
        watchBookmarksUseCase(),
      ).thenAnswer((_) => bookmarksController.stream);
      when(
        addBookmarkUseCase.call(params: anyNamed('params')),
      ).thenAnswer((_) async {});
      when(
        removeBookmarkUseCase.call(params: anyNamed('params')),
      ).thenAnswer((_) async {});
    });

    tearDown(() async {
      await bookmarksController.close();
    });

    test('starts with BookmarksLoading', () {
      final bloc = BookmarkBloc(
        watchBookmarksUseCase,
        addBookmarkUseCase,
        removeBookmarkUseCase,
      );

      expect(bloc.state, const BookmarksLoading());
      bloc.close();
    });

    blocTest<BookmarkBloc, BookmarkState>(
      'emits BookmarksDone after GetBookmarksEvent',
      build: () => BookmarkBloc(
        watchBookmarksUseCase,
        addBookmarkUseCase,
        removeBookmarkUseCase,
      ),
      act: (bloc) async {
        bloc.add(const GetBookmarksEvent());
        await Future<void>.delayed(Duration.zero);
        bookmarksController.add(const [bookmark]);
      },
      expect: () => [
        const BookmarksDone([bookmark]),
      ],
      verify: (_) {
        verify(watchBookmarksUseCase()).called(1);
        verifyNever(addBookmarkUseCase.call(params: anyNamed('params')));
        verifyNever(removeBookmarkUseCase.call(params: anyNamed('params')));
      },
    );

    blocTest<BookmarkBloc, BookmarkState>(
      'calls add use case then refreshes bookmarks on AddBookmarkEvent',
      build: () => BookmarkBloc(
        watchBookmarksUseCase,
        addBookmarkUseCase,
        removeBookmarkUseCase,
      ),
      act: (bloc) async {
        bloc.add(const GetBookmarksEvent());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const AddBookmarkEvent(bookmark));
        await Future<void>.delayed(Duration.zero);
        bookmarksController.add(const [bookmark]);
      },
      expect: () => [
        const BookmarksDone([bookmark]),
      ],
      verify: (_) {
        final captured = verify(
          addBookmarkUseCase.call(params: captureAnyNamed('params')),
        ).captured;
        expect(captured.single.bookmark, bookmark);
        verify(watchBookmarksUseCase()).called(1);
      },
    );

    blocTest<BookmarkBloc, BookmarkState>(
      'calls remove use case then refreshes bookmarks on RemoveBookmarkEvent',
      build: () => BookmarkBloc(
        watchBookmarksUseCase,
        addBookmarkUseCase,
        removeBookmarkUseCase,
      ),
      act: (bloc) async {
        bloc.add(const GetBookmarksEvent());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const RemoveBookmarkEvent('id-1', ArticleSource.api));
        await Future<void>.delayed(Duration.zero);
        bookmarksController.add(const [bookmark]);
      },
      expect: () => [
        const BookmarksDone([bookmark]),
      ],
      verify: (_) {
        final captured = verify(
          removeBookmarkUseCase.call(params: captureAnyNamed('params')),
        ).captured;
        expect(captured.single.sourceId, 'id-1');
        expect(captured.single.source, ArticleSource.api);
        verify(watchBookmarksUseCase()).called(1);
      },
    );
  });
}
