import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/article_source.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/bookmark_entity.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/repository/bookmark_repository.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/usecases/add_bookmark.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/usecases/bookmark_params.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/usecases/is_bookmarked.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/usecases/get_bookmarks.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/usecases/remove_bookmark.dart';

import 'bookmark_usecases_test.mocks.dart';

@GenerateNiceMocks([MockSpec<BookmarkRepository>()])
void main() {
  group('Bookmark use cases', () {
    late MockBookmarkRepository repository;

    setUp(() {
      repository = MockBookmarkRepository();
    });

    test(
      'WatchBookmarksUseCase delegates to repository and returns bookmarks',
      () async {
        const expected = [
          BookmarkEntity(
            sourceId: 'id-1',
            source: ArticleSource.api,
            title: 'A',
          ),
        ];
        when(
          repository.watchBookmarks(),
        ).thenAnswer((_) => Stream.value(expected));

        final useCase = WatchBookmarksUseCase(repository);
        final result = await useCase().first;

        expect(result, expected);
        verify(repository.watchBookmarks()).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    test(
      'AddBookmarkUseCase delegates bookmark payload to repository',
      () async {
        const bookmark = BookmarkEntity(
          sourceId: 'id-1',
          source: ArticleSource.community,
          title: 'Saved article',
        );
        when(repository.addBookmark(bookmark)).thenAnswer((_) async {});

        final useCase = AddBookmarkUseCase(repository);
        await useCase(params: const BookmarkParams(bookmark: bookmark));

        verify(repository.addBookmark(bookmark)).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    test(
      'RemoveBookmarkUseCase delegates source identifier to repository',
      () async {
        when(
          repository.removeBookmark('id-1', ArticleSource.api),
        ).thenAnswer((_) async {});

        final useCase = RemoveBookmarkUseCase(repository);
        await useCase(
          params: const BookmarkIdentifierParams(
            sourceId: 'id-1',
            source: ArticleSource.api,
          ),
        );

        verify(repository.removeBookmark('id-1', ArticleSource.api)).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    test('IsBookmarkedUseCase delegates identifier and returns bool', () async {
      when(
        repository.isBookmarked('id-1', ArticleSource.community),
      ).thenAnswer((_) async => true);

      final useCase = IsBookmarkedUseCase(repository);
      final result = await useCase(
        params: const BookmarkIdentifierParams(
          sourceId: 'id-1',
          source: ArticleSource.community,
        ),
      );

      expect(result, isTrue);
      verify(
        repository.isBookmarked('id-1', ArticleSource.community),
      ).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
