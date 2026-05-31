import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/article_source.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/bookmark_entity.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/repository/bookmark_repository.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/usecases/add_bookmark.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/usecases/get_bookmarks.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/usecases/remove_bookmark.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_bloc.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_event.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/pages/saved_articles_screen.dart';
import 'dart:async';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Bookmarks feature integration', () {
    testWidgets('loads saved items and removes one from UI flow', (
      tester,
    ) async {
      final repository = _InMemoryBookmarkRepository(
        initial: const [
          BookmarkEntity(
            sourceId: 'api-1',
            source: ArticleSource.api,
            title: 'API Story',
            description: 'Top line',
          ),
          BookmarkEntity(
            sourceId: 'community-1',
            source: ArticleSource.community,
            title: 'Community Story',
            description: 'From users',
          ),
        ],
      );

      final bloc = BookmarkBloc(
        WatchBookmarksUseCase(repository),
        AddBookmarkUseCase(repository),
        RemoveBookmarkUseCase(repository),
      );

      bloc.add(const GetBookmarksEvent());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: BlocProvider<BookmarkBloc>.value(
            value: bloc,
            child: const SavedArticlesScreen(),
          ),
        ),
      );

      // Flush initial stream emission and bloc state update.
      await tester.pump();
      await tester.pump();

      expect(find.text('2 ARTICLES'), findsOneWidget);
      expect(find.text('API Story'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.bookmark).first);
      // Flush remove handler + stream emission + rebuild.
      await tester.pump();
      await tester.pump();

      expect(find.text('1 ARTICLE'), findsOneWidget);
      expect(find.text('API Story'), findsNothing);
      expect(find.text('Community Story'), findsOneWidget);

      await bloc.close();
      await repository.dispose();
    });
  });
}

class _InMemoryBookmarkRepository implements BookmarkRepository {
  _InMemoryBookmarkRepository({required List<BookmarkEntity> initial})
    : _bookmarks = [...initial];

  final List<BookmarkEntity> _bookmarks;
  final StreamController<List<BookmarkEntity>> _controller =
      StreamController<List<BookmarkEntity>>.broadcast();
  bool _watching = false;

  void _emitCurrent() {
    if (_watching && !_controller.isClosed) {
      _controller.add(List.unmodifiable(_bookmarks));
    }
  }

  @override
  Future<void> addBookmark(BookmarkEntity bookmark) async {
    _bookmarks.removeWhere(
      (item) =>
          item.sourceId == bookmark.sourceId && item.source == bookmark.source,
    );
    _bookmarks.insert(0, bookmark);
    _emitCurrent();
  }

  @override
  Stream<List<BookmarkEntity>> watchBookmarks() {
    if (!_watching) {
      _watching = true;
      scheduleMicrotask(_emitCurrent);
    }
    return _controller.stream;
  }

  @override
  Future<bool> isBookmarked(String sourceId, ArticleSource source) async {
    return _bookmarks.any(
      (item) => item.sourceId == sourceId && item.source == source,
    );
  }

  @override
  Future<void> removeBookmark(String sourceId, ArticleSource source) async {
    _bookmarks.removeWhere(
      (item) => item.sourceId == sourceId && item.source == source,
    );
    _emitCurrent();
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
