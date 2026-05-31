import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/paginated_result.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_bloc.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_event.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

class MockBookmarkBloc extends MockBloc<BookmarkEvent, BookmarkState>
    implements BookmarkBloc {}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(const GetBookmarksEvent());
  });

  testWidgets('tapping feed bookmark icon dispatches add bookmark event', (
    tester,
  ) async {
    const article = ArticleEntity(
      title: 'Feed article',
      description: 'Feed lede',
      url: 'https://example.com/feed-article',
      urlToImage: 'https://example.com/image.jpg',
      author: 'Reporter',
      publishedAt: '2026-05-30T00:00:00Z',
      content: 'Feed body',
    );
    const compactArticle = ArticleEntity(
      title: 'Compact feed article',
      description: 'Compact feed lede',
      url: 'https://example.com/compact-feed-article',
      urlToImage: 'https://example.com/compact-image.jpg',
      author: 'Reporter',
      publishedAt: '2026-05-30T00:00:00Z',
      content: 'Compact feed body',
    );
    final remoteBloc = RemoteArticlesBloc(
      GetArticleUseCase(_FakeArticleRepository([article, compactArticle])),
    )..add(const GetArticles());
    final bookmarkBloc = MockBookmarkBloc();

    when(() => bookmarkBloc.state).thenReturn(const BookmarksDone([]));
    whenListen(
      bookmarkBloc,
      const Stream<BookmarkState>.empty(),
      initialState: const BookmarksDone([]),
    );

    await tester.pumpDailyNews(remoteBloc, bookmarkBloc);
    await tester.pump();

    await tester.tap(find.byIcon(Icons.bookmark_border).last);
    await tester.pump();

    verify(
      () => bookmarkBloc.add(
        any(
          that: isA<AddBookmarkEvent>().having(
            (event) => event.bookmark.sourceId,
            'sourceId',
            'https://example.com/compact-feed-article',
          ),
        ),
      ),
    ).called(1);
  });
}

class _FakeArticleRepository implements ArticleRepository {
  const _FakeArticleRepository(this.articles);

  final List<ArticleEntity> articles;

  @override
  Future<DataState<PaginatedResult<ArticleEntity>>> getNewsArticles({
    required ArticleParams params,
  }) async {
    return DataSuccess(
      PaginatedResult(
        page: params.page,
        pageSize: params.pageSize,
        totalResults: articles.length,
        articles: articles,
      ),
    );
  }
}

extension on WidgetTester {
  Future<void> pumpDailyNews(
    RemoteArticlesBloc remoteBloc,
    BookmarkBloc bookmarkBloc,
  ) async {
    await pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<RemoteArticlesBloc>.value(value: remoteBloc),
          BlocProvider<BookmarkBloc>.value(value: bookmarkBloc),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DailyNews(),
        ),
      ),
    );
    await pump();
  }
}
