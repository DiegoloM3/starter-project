import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/errors/error_keys.dart';
import 'package:news_app_clean_architecture/core/errors/exceptions.dart';
import 'package:news_app_clean_architecture/features/bookmarks/data/datasources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/bookmarks/data/datasources/local/dao/bookmark_dao.dart';
import 'package:news_app_clean_architecture/features/bookmarks/data/datasources/local/local_bookmarks_datasource.dart';
import 'package:news_app_clean_architecture/features/bookmarks/data/models/bookmark_model.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/article_source.dart';

import 'local_bookmarks_datasource_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AppDatabase>(), MockSpec<BookmarkDao>()])
void main() {
  group('LocalBookmarksDataSource', () {
    late MockAppDatabase database;
    late MockBookmarkDao bookmarkDao;
    late LocalBookmarksDataSource dataSource;

    setUp(() {
      database = MockAppDatabase();
      bookmarkDao = MockBookmarkDao();
      when(database.bookmarkDao).thenReturn(bookmarkDao);
      dataSource = LocalBookmarksDataSource(database);
    });

    test('getBookmarks returns dao result on success', () async {
      const expected = [
        BookmarkModel(sourceId: 'id-1', source: ArticleSource.api, title: 'A'),
      ];
      when(bookmarkDao.getAllBookmarks()).thenAnswer((_) async => expected);

      final result = await dataSource.getBookmarks();

      expect(result, expected);
      verify(bookmarkDao.getAllBookmarks()).called(1);
    });

    test(
      'getBookmarks throws CacheException(generic) on dao failure',
      () async {
        when(bookmarkDao.getAllBookmarks()).thenThrow(Exception('db failed'));

        expect(
          dataSource.getBookmarks(),
          throwsA(
            isA<CacheException>().having(
              (e) => e.message,
              'message',
              CacheErrorKeys.generic,
            ),
          ),
        );
      },
    );

    test('addBookmark delegates to dao on success', () async {
      const bookmark = BookmarkModel(
        sourceId: 'id-2',
        source: ArticleSource.community,
        title: 'Saved',
      );
      when(bookmarkDao.insertBookmark(bookmark)).thenAnswer((_) async {});

      await dataSource.addBookmark(bookmark);

      verify(bookmarkDao.insertBookmark(bookmark)).called(1);
    });

    test(
      'addBookmark throws CacheException(writeError) on dao failure',
      () async {
        const bookmark = BookmarkModel(
          sourceId: 'id-2',
          source: ArticleSource.community,
        );
        when(
          bookmarkDao.insertBookmark(bookmark),
        ).thenThrow(Exception('db failed'));

        expect(
          dataSource.addBookmark(bookmark),
          throwsA(
            isA<CacheException>().having(
              (e) => e.message,
              'message',
              CacheErrorKeys.writeError,
            ),
          ),
        );
      },
    );

    test('removeBookmark delegates to dao with source.name', () async {
      when(bookmarkDao.deleteBookmark('id-3', 'api')).thenAnswer((_) async {});

      await dataSource.removeBookmark('id-3', ArticleSource.api);

      verify(bookmarkDao.deleteBookmark('id-3', 'api')).called(1);
    });

    test(
      'removeBookmark throws CacheException(writeError) on dao failure',
      () async {
        when(
          bookmarkDao.deleteBookmark('id-3', 'api'),
        ).thenThrow(Exception('db failed'));

        expect(
          dataSource.removeBookmark('id-3', ArticleSource.api),
          throwsA(
            isA<CacheException>().having(
              (e) => e.message,
              'message',
              CacheErrorKeys.writeError,
            ),
          ),
        );
      },
    );

    test('isBookmarked returns true when dao finds bookmark', () async {
      const bookmark = BookmarkModel(
        sourceId: 'id-4',
        source: ArticleSource.api,
      );
      when(
        bookmarkDao.findBookmark('id-4', 'api'),
      ).thenAnswer((_) async => bookmark);

      final result = await dataSource.isBookmarked('id-4', ArticleSource.api);

      expect(result, isTrue);
      verify(bookmarkDao.findBookmark('id-4', 'api')).called(1);
    });

    test('isBookmarked returns false when dao returns null', () async {
      when(
        bookmarkDao.findBookmark('id-4', 'api'),
      ).thenAnswer((_) async => null);

      final result = await dataSource.isBookmarked('id-4', ArticleSource.api);

      expect(result, isFalse);
      verify(bookmarkDao.findBookmark('id-4', 'api')).called(1);
    });

    test(
      'isBookmarked throws CacheException(generic) on dao failure',
      () async {
        when(
          bookmarkDao.findBookmark('id-4', 'api'),
        ).thenThrow(Exception('db failed'));

        expect(
          dataSource.isBookmarked('id-4', ArticleSource.api),
          throwsA(
            isA<CacheException>().having(
              (e) => e.message,
              'message',
              CacheErrorKeys.generic,
            ),
          ),
        );
      },
    );
  });
}
