import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/paths.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/articles_list.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/login_bloc.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

class MockRemoteArticlesBloc
    extends MockBloc<RemoteArticlesEvent, RemoteArticlesState>
    implements RemoteArticlesBloc {}

class MockLocalArticlesBloc
    extends MockBloc<LocalArticlesEvent, LocalArticlesState>
    implements LocalArticleBloc {}

class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}

class DummyArticle extends ArticleEntity {
  const DummyArticle({
    String? id,
    String? author,
    String? title,
    String? description,
    String? url,
    String? publishedAt,
    String? content,
  }) : super(
          id: id,
          author: author,
          title: title,
          description: description,
          url: url,
          publishedAt: publishedAt,
          content: content,
        );
}

void main() {
  late MockRemoteArticlesBloc mockRemoteArticlesBloc;
  late MockLocalArticlesBloc mockLocalArticlesBloc;
  late MockLoginBloc mockLoginBloc;
  late GetIt getIt;

  setUp(() {
    mockRemoteArticlesBloc = MockRemoteArticlesBloc();
    mockLocalArticlesBloc = MockLocalArticlesBloc();
    mockLoginBloc = MockLoginBloc();
    getIt = GetIt.instance;
    if (getIt.isRegistered<RemoteArticlesBloc>()) {
      getIt.unregister<RemoteArticlesBloc>();
    }
    if (getIt.isRegistered<LocalArticleBloc>()) {
      getIt.unregister<LocalArticleBloc>();
    }
    if (getIt.isRegistered<LoginBloc>()) {
      getIt.unregister<LoginBloc>();
    }
    getIt.registerSingleton<RemoteArticlesBloc>(mockRemoteArticlesBloc);
    getIt.registerSingleton<LocalArticleBloc>(mockLocalArticlesBloc);
    getIt.registerSingleton<LoginBloc>(mockLoginBloc);
  });

  tearDown(() {
    if (getIt.isRegistered<RemoteArticlesBloc>()) {
      getIt.unregister<RemoteArticlesBloc>();
    }
    if (getIt.isRegistered<LocalArticleBloc>()) {
      getIt.unregister<LocalArticleBloc>();
    }
    if (getIt.isRegistered<LoginBloc>()) {
      getIt.unregister<LoginBloc>();
    }
  });

  group('ArticlesList', () {
    final List<ArticleEntity> mockArticles = [
      const DummyArticle(
          id: '1',
          title: 'Article 1',
          url: 'https://example.com/1',
          publishedAt: '2023-10-27T10:00:00Z'),
      const DummyArticle(
          id: '2',
          title: 'Article 2',
          url: 'https://example.com/2',
          publishedAt: '2023-10-27T11:00:00Z'),
    ];

    testWidgets('renders correct number of ArticleWidgets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticlesList(
              articles: mockArticles,
            ),
          ),
        ),
      );

      expect(find.byType(ArticleWidget), findsNWidgets(2));
    });

    testWidgets('handles onRemove correctly when isRemovable is true',
        (WidgetTester tester) async {
      bool removeCalled = false;
      ArticleEntity? removedArticle;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticlesList(
              articles: mockArticles,
              isRemovable: true,
              onRemove: (article) {
                removeCalled = true;
                removedArticle = article;
              },
            ),
          ),
        ),
      );

      final closeIcons = find.byIcon(Icons.close);
      expect(closeIcons, findsNWidgets(2));

      await tester.tap(closeIcons.first);
      await tester.pump();

      expect(removeCalled, isTrue);
      expect(removedArticle, mockArticles.first);
    });

    testWidgets('does not show close icons if isRemovable is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticlesList(
              articles: mockArticles,
              isRemovable: false,
            ),
          ),
        ),
      );

      expect(find.byType(ArticleWidget), findsNWidgets(2));
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('renders empty list when articles is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ArticlesList(
              articles: [],
            ),
          ),
        ),
      );

      expect(find.byType(ArticleWidget), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows CircularProgressIndicator when isLast is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticlesList(
              articles: mockArticles,
              isLast: false,
            ),
          ),
        ),
      );

      expect(find.byType(ArticleWidget), findsNWidgets(mockArticles.length - 1));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not show CircularProgressIndicator when isLast is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticlesList(
              articles: mockArticles,
              isLast: true,
            ),
          ),
        ),
      );

      expect(find.byType(ArticleWidget), findsNWidgets(mockArticles.length));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('uses the provided ScrollController',
        (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticlesList(
              articles: mockArticles,
              scrollController: controller,
            ),
          ),
        ),
      );

      final ListView listView = tester.widget(find.byType(ListView));
      expect(listView.controller, equals(controller));
    });

    testWidgets('has correct physics and cacheExtent',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticlesList(
              articles: mockArticles,
            ),
          ),
        ),
      );

      final ListView listView = tester.widget(find.byType(ListView));
      expect(listView.physics, isA<AlwaysScrollableScrollPhysics>());
      expect(listView.cacheExtent, equals(500.0));
    });

    testWidgets('navigates to ArticleDetails when an article is pressed',
        (WidgetTester tester) async {
      final dummyArticle = mockArticles.first;

      when(() => mockRemoteArticlesBloc.state).thenReturn(
          RemoteArticlesDone(articles: [dummyArticle], totalPages: 1));

      when(() => mockLocalArticlesBloc.state).thenReturn(
        const LocalArticlesDone(articles: [], isSaved: false),
      );

      when(() => mockLoginBloc.state).thenReturn(LoginInitial());

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<RemoteArticlesBloc>.value(
                value: mockRemoteArticlesBloc),
            BlocProvider<LocalArticleBloc>.value(value: mockLocalArticlesBloc),
            BlocProvider<LoginBloc>.value(value: mockLoginBloc),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: GoRouter(
              initialLocation: Paths.dailyNews.path,
              routes: AppRoutes.list,
            ),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Article 1'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.byIcon(Ionicons.bookmark_outline), findsOneWidget);
    });
  });
}
