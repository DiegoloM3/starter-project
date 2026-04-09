import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/local_database_exception.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/saved_articles/saved_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/articles_list.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations_en.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockLocalArticleBloc
    extends MockBloc<LocalArticlesEvent, LocalArticlesState>
    implements LocalArticleBloc {}

void main() {
  late MockLocalArticleBloc mockLocalArticleBloc;

  setUpAll(() {
    registerFallbackValue(const ArticleEntity());
  });

  setUp(() async {
    mockLocalArticleBloc = MockLocalArticleBloc();
    await sl.reset();
    sl.registerFactory<LocalArticleBloc>(() => mockLocalArticleBloc);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<LocalArticleBloc>.value(
        value: mockLocalArticleBloc,
        child: const SavedArticles(),
      ),
    );
  }

  const testArticle = ArticleEntity(
    id: '1',
    title: 'Test Title',
    author: 'Test Author',
    description: 'Test Description',
    url: 'https://example.com',
    publishedAt: '2023-10-27',
  );

  group('SavedArticles Widget Tests', () {
    testWidgets(
        'Should display CupertinoActivityIndicator when state is Loading',
        (tester) async {
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets('Should display "NO SAVED ARTICLES" when state is Empty',
        (tester) async {
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticleEmpty());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text(AppLocalizationsEn().no_saved_articles), findsOneWidget);
    });

    testWidgets('Should display "ERROR" when state is Error', (tester) async {
      when(() => mockLocalArticleBloc.state).thenReturn(
        const LocalArticlesError(
          LocalDatabaseUnknownException(message: 'test'),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text(AppLocalizationsEn().error), findsOneWidget);
    });

    testWidgets('Should display ArticlesList when state is Done with articles',
        (tester) async {
      when(() => mockLocalArticleBloc.state).thenReturn(const LocalArticlesDone(
          articles: [testArticle], status: LocalArticleStatus.none));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(ArticlesList), findsOneWidget);
      expect(find.text(testArticle.title!), findsOneWidget);
    });

    testWidgets('Should show SnackBar when status changes to savedSuccess',
        (tester) async {
      whenListen(
        mockLocalArticleBloc,
        Stream.fromIterable([
          const LocalArticlesDone(
              articles: [], status: LocalArticleStatus.none),
          const LocalArticlesDone(
              articles: [], status: LocalArticleStatus.savedSuccess),
        ]),
        initialState: const LocalArticlesDone(
            articles: [], status: LocalArticleStatus.none),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text(AppLocalizationsEn().saved_article), findsOneWidget);
    });

    testWidgets('Should show SnackBar when status changes to deletedSuccess',
        (tester) async {
      whenListen(
        mockLocalArticleBloc,
        Stream.fromIterable([
          const LocalArticlesDone(
              articles: [], status: LocalArticleStatus.none),
          const LocalArticlesDone(
              articles: [], status: LocalArticleStatus.deletedSuccess),
        ]),
        initialState: const LocalArticlesDone(
            articles: [], status: LocalArticleStatus.none),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text(AppLocalizationsEn().deleted_article), findsOneWidget);
    });

    testWidgets('Should show SnackBar when status changes to genericError',
        (tester) async {
      whenListen(
        mockLocalArticleBloc,
        Stream.fromIterable([
          const LocalArticlesDone(
              articles: [], status: LocalArticleStatus.none),
          const LocalArticlesDone(
              articles: [], status: LocalArticleStatus.genericError),
        ]),
        initialState: const LocalArticlesDone(
            articles: [], status: LocalArticleStatus.none),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text(AppLocalizationsEn().generic_error), findsOneWidget);
    });

    testWidgets(
        'Should add RemoveArticle event when remove button is pressed on an article',
        (tester) async {
      when(() => mockLocalArticleBloc.state).thenReturn(const LocalArticlesDone(
          articles: [testArticle], status: LocalArticleStatus.none));

      await tester.pumpWidget(createWidgetUnderTest());

      final removeButton = find.byIcon(Icons.close);
      expect(removeButton, findsOneWidget);

      await tester.tap(removeButton);
      await tester.pump();

      verify(() => mockLocalArticleBloc.add(const RemoveArticle(testArticle)))
          .called(1);
    });

    testWidgets('Should display correct AppBar title', (tester) async {
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text(AppLocalizationsEn().saved_articles), findsOneWidget);
    });
  });
}
