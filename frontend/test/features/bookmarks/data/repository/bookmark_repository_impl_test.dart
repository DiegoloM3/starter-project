import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/features/bookmarks/data/datasources/local/local_bookmarks_datasource.dart';
import 'package:news_app_clean_architecture/features/bookmarks/data/models/bookmark_model.dart';
import 'package:news_app_clean_architecture/features/bookmarks/data/repository/bookmark_repository_impl.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/article_source.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/bookmark_entity.dart';

import 'bookmark_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<LocalBookmarksDataSource>()])
void main() {
  group('BookmarkRepositoryImpl', () {
    late MockLocalBookmarksDataSource localDataSource;
    late BookmarkRepositoryImpl repository;

    setUp(() {
      localDataSource = MockLocalBookmarksDataSource();
      repository = BookmarkRepositoryImpl(localDataSource);
    });

    test(
      'watchBookmarks maps BookmarkModel stream to BookmarkEntity stream',
      () async {
        const models = [
          BookmarkModel(
            sourceId: 'id-1',
            source: ArticleSource.api,
            title: 'Headline',
            description: 'Description',
          ),
        ];
        when(
          localDataSource.watchBookmarks(),
        ).thenAnswer((_) => Stream.value(models));

        final result = await repository.watchBookmarks().first;

        expect(result, hasLength(1));
        expect(result.first.sourceId, 'id-1');
        expect(result.first.source, ArticleSource.api);
        expect(result.first.title, 'Headline');
        verify(localDataSource.watchBookmarks()).called(1);
        verifyNoMoreInteractions(localDataSource);
      },
    );

    test(
      'addBookmark converts entity to model and delegates to datasource',
      () async {
        const bookmark = BookmarkEntity(
          sourceId: 'id-2',
          source: ArticleSource.community,
          title: 'Community story',
          author: 'Alex',
        );
        when(localDataSource.addBookmark(any)).thenAnswer((_) async {});

        await repository.addBookmark(bookmark);

        final captured = verify(
          localDataSource.addBookmark(captureAny),
        ).captured;
        final model = captured.single as BookmarkModel;
        expect(model.sourceId, bookmark.sourceId);
        expect(model.source, bookmark.source);
        expect(model.title, bookmark.title);
        expect(model.author, bookmark.author);
        verifyNoMoreInteractions(localDataSource);
      },
    );

    test('removeBookmark delegates sourceId/source to datasource', () async {
      when(
        localDataSource.removeBookmark('id-3', ArticleSource.api),
      ).thenAnswer((_) async {});

      await repository.removeBookmark('id-3', ArticleSource.api);

      verify(
        localDataSource.removeBookmark('id-3', ArticleSource.api),
      ).called(1);
      verifyNoMoreInteractions(localDataSource);
    });

    test('isBookmarked delegates and returns bool result', () async {
      when(
        localDataSource.isBookmarked('id-4', ArticleSource.community),
      ).thenAnswer((_) async => true);

      final result = await repository.isBookmarked(
        'id-4',
        ArticleSource.community,
      );

      expect(result, isTrue);
      verify(
        localDataSource.isBookmarked('id-4', ArticleSource.community),
      ).called(1);
      verifyNoMoreInteractions(localDataSource);
    });
  });
}
