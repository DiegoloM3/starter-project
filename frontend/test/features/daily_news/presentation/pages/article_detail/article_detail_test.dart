import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/base_network_image.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:network_image_mock/network_image_mock.dart';

class MockLocalArticleBloc
    extends MockBloc<LocalArticlesEvent, LocalArticlesState>
    implements LocalArticleBloc {}

class FakeLocalArticleEvent extends Fake implements LocalArticlesEvent {}

class FakeRoute extends Fake implements Route<dynamic> {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockLocalArticleBloc mockLocalArticleBloc;

  const testArticle = ArticleEntity(
    id: '1',
    title: 'Test Title',
    publishedAt: '2023-10-27T10:00:00Z',
    url: 'https://example.com/image.jpg',
    description: 'Test Description',
    content: 'Test Content',
  );

  setUpAll(() {
    registerFallbackValue(FakeLocalArticleEvent());
    registerFallbackValue(FakeRoute());
  });

  setUp(() async {
    mockLocalArticleBloc = MockLocalArticleBloc();
    await sl.reset();
    sl.registerFactory<LocalArticleBloc>(() => mockLocalArticleBloc);
  });

  Widget createWidgetUnderTest(
      {ArticleEntity article = testArticle,
      List<NavigatorObserver> observers = const []}) {
    return BlocProvider<LocalArticleBloc>.value(
      value: mockLocalArticleBloc,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ArticleDetailsView(article: article),
        navigatorObservers: observers,
      ),
    );
  }

  group('ArticleDetailsView Widget Tests', () {
    testWidgets(
        'Should render the article details correctly (Title, Date, Description, Content, Image)',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(() => mockLocalArticleBloc.state)
            .thenReturn(const LocalArticlesLoading());

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text(testArticle.title!), findsOneWidget);
        expect(find.text('10/27/2023'), findsOneWidget);
        expect(find.text(testArticle.description!), findsOneWidget);
        expect(find.byType(MarkdownBody), findsOneWidget);
        expect(find.text(testArticle.content!), findsOneWidget);
        expect(find.byType(BaseNetworkImage), findsOneWidget);
      });
    });

    testWidgets('Should show bookmark_outline icon when article is NOT saved',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(() => mockLocalArticleBloc.state).thenReturn(
          const LocalArticlesDone(articles: [], isSaved: false),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byIcon(Ionicons.bookmark_outline), findsOneWidget);
        expect(find.byIcon(Ionicons.bookmark), findsNothing);
      });
    });

    testWidgets('Should show bookmark icon when article IS saved',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(() => mockLocalArticleBloc.state).thenReturn(
          const LocalArticlesDone(articles: [], isSaved: true),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byIcon(Ionicons.bookmark), findsOneWidget);
        expect(find.byIcon(Ionicons.bookmark_outline), findsNothing);
      });
    });

    testWidgets('Should hide FAB icons when isSaved is null',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(() => mockLocalArticleBloc.state).thenReturn(
          const LocalArticlesLoading(),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byIcon(Ionicons.bookmark), findsNothing);
        expect(find.byIcon(Ionicons.bookmark_outline), findsNothing);
      });
    });

    testWidgets(
        'Should trigger SaveArticle event and show SnackBar when NOT saved and FAB is pressed',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(() => mockLocalArticleBloc.state).thenReturn(
          const LocalArticlesDone(articles: [], isSaved: false),
        );
        when(() => mockLocalArticleBloc.add(any())).thenAnswer((_) async {});

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        verify(() => mockLocalArticleBloc.add(const SaveArticle(testArticle)))
            .called(1);

        await tester.pump(const Duration(milliseconds: 750));

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Article saved successfully.'), findsOneWidget);
      });
    });

    testWidgets(
        'Should trigger RemoveArticle event and show SnackBar when IS saved and FAB is pressed',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(() => mockLocalArticleBloc.state).thenReturn(
          const LocalArticlesDone(articles: [], isSaved: true),
        );
        when(() => mockLocalArticleBloc.add(any())).thenAnswer((_) async {});

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        verify(() => mockLocalArticleBloc.add(const RemoveArticle(testArticle)))
            .called(1);

        await tester.pump(const Duration(milliseconds: 750));

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Article removed successfully.'), findsOneWidget);
      });
    });

    testWidgets('Should not render the description if it is null or empty',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        const articleNoDesc = ArticleEntity(
          id: '2',
          title: 'No Desc',
          url: 'https://example.com/image.jpg',
          description: null,
          content: 'Content',
        );

        when(() => mockLocalArticleBloc.state).thenReturn(
          const LocalArticlesDone(articles: [], isSaved: false),
        );

        await tester.pumpWidget(createWidgetUnderTest(article: articleNoDesc));

        expect(find.text(testArticle.description!), findsNothing);

        const articleEmptyDesc = ArticleEntity(
          id: '3',
          title: 'Empty Desc',
          url: 'https://example.com/image.jpg',
          description: '',
          content: 'Content',
        );

        await tester.pumpWidget(createWidgetUnderTest(article: articleEmptyDesc));
        expect(
          find.byWidgetPredicate((widget) =>
              widget is Text &&
              widget.data == '' &&
              widget.style?.fontSize == 16.0),
          findsNothing,
        );
      });
    });

    testWidgets(
        'Should trigger ClearBookmark and pop the navigator when back button is pressed',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(() => mockLocalArticleBloc.state).thenReturn(
          const LocalArticleEmpty(),
        );

        final navObserver = MockNavigatorObserver();
        await tester.pumpWidget(
            createWidgetUnderTest(observers: [navObserver]));

        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pumpAndSettle();

        verify(() => mockLocalArticleBloc.add(const ClearBookmark())).called(1);
        verify(() => navObserver.didPop(any(), any())).called(1);
      });
    });

    testWidgets('Should trigger GetSavedArticle when widget is built',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(() => mockLocalArticleBloc.state).thenReturn(
          const LocalArticlesLoading(),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        verify(() => mockLocalArticleBloc.add(GetSavedArticle(testArticle.id!)))
            .called(1);
      });
    });
  });
}
