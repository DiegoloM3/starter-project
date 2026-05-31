import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/article_source.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/bookmark_entity.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_bloc.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_event.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_state.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/pages/saved_articles_screen.dart';

class MockBookmarkBloc extends MockBloc<BookmarkEvent, BookmarkState>
    implements BookmarkBloc {}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(const GetBookmarksEvent());
  });

  group('SavedArticlesScreen', () {
    const first = BookmarkEntity(
      sourceId: 'id-1',
      source: ArticleSource.api,
      title: 'First saved',
      description: 'Lead story',
    );
    const second = BookmarkEntity(
      sourceId: 'id-2',
      source: ArticleSource.community,
      title: 'Second saved',
      description: 'Community story',
    );

    testWidgets('renders empty state when no bookmarks exist', (tester) async {
      final bloc = MockBookmarkBloc();
      when(() => bloc.state).thenReturn(const BookmarksDone([]));
      whenListen(
        bloc,
        const Stream<BookmarkState>.empty(),
        initialState: const BookmarksDone([]),
      );

      await tester.pumpBookmarksScreen(bloc);

      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('0 ARTICLES'), findsOneWidget);
      expect(
        find.text(
          'No saved articles yet.\nTap the bookmark icon on any article to save it.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders hero + compact list when bookmarks exist', (
      tester,
    ) async {
      final bloc = MockBookmarkBloc();
      const bookmarks = [first, second];
      when(() => bloc.state).thenReturn(const BookmarksDone(bookmarks));
      whenListen(
        bloc,
        const Stream<BookmarkState>.empty(),
        initialState: const BookmarksDone(bookmarks),
      );

      await tester.pumpBookmarksScreen(bloc);

      expect(find.text('2 ARTICLES'), findsOneWidget);
      expect(find.text('First saved'), findsOneWidget);
      expect(find.text('Second saved'), findsOneWidget);
      expect(find.text('NEWS'), findsWidgets);
      expect(find.text('COMMUNITY'), findsOneWidget);
    });

    testWidgets('tapping bookmark icon dispatches remove use case', (
      tester,
    ) async {
      final bloc = MockBookmarkBloc();
      const bookmarks = [first];
      when(() => bloc.state).thenReturn(const BookmarksDone(bookmarks));
      whenListen(
        bloc,
        const Stream<BookmarkState>.empty(),
        initialState: const BookmarksDone(bookmarks),
      );

      await tester.pumpBookmarksScreen(bloc);

      // Tap the bookmark icon in the hero card overlay to remove it.
      await tester.tap(find.byIcon(Icons.bookmark).first);
      await tester.pump();

      verify(
        () => bloc.add(const RemoveBookmarkEvent('id-1', ArticleSource.api)),
      ).called(1);
    });
  });
}

extension on WidgetTester {
  /// Builds the widget and flushes short frames to settle first paint.
  Future<void> pumpBookmarksScreen(BookmarkBloc bloc) async {
    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider<BookmarkBloc>.value(
          value: bloc,
          child: const SavedArticlesScreen(),
        ),
      ),
    );

    // Render initial bloc state.
    await pump();
  }
}
