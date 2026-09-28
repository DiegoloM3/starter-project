import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/edit/edit_article_bloc.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/user/user_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/news/presentation/pages/my_articles/my_articles_page.dart';

class MockUserArticlesBloc
    extends MockBloc<UserArticlesEvent, UserArticlesState>
    implements UserArticlesBloc {}

class MockEditArticleBloc
    extends MockBloc<EditArticleEvent, EditArticleState>
    implements EditArticleBloc {}

void main() {
  const tArticles = [
    ArticleEntity(
      id: 'art-1',
      authorDisplayName: 'Jane',
      title: 'First article',
      publishedAt: '2026-09-27T00:00:00Z',
      content: 'First content',
    ),
    ArticleEntity(
      id: 'art-2',
      authorDisplayName: 'Jane',
      title: 'Second article',
      publishedAt: '2026-09-26T00:00:00Z',
      content: 'Second content',
    ),
  ];

  late MockUserArticlesBloc mockUserArticlesBloc;
  late MockEditArticleBloc mockEditArticleBloc;

  setUp(() {
    mockUserArticlesBloc = MockUserArticlesBloc();
    mockEditArticleBloc = MockEditArticleBloc();

    whenListen(
      mockUserArticlesBloc,
      const Stream<UserArticlesState>.empty(),
      initialState: const UserArticlesDone(tArticles),
    );
    whenListen(
      mockEditArticleBloc,
      const Stream<EditArticleState>.empty(),
      initialState: const EditArticleIdle(),
    );

    final sl = GetIt.instance;
    if (sl.isRegistered<UserArticlesBloc>()) {
      sl.unregister<UserArticlesBloc>();
    }
    if (sl.isRegistered<EditArticleBloc>()) {
      sl.unregister<EditArticleBloc>();
    }
    sl.registerFactory<UserArticlesBloc>(() => mockUserArticlesBloc);
    sl.registerFactory<EditArticleBloc>(() => mockEditArticleBloc);
  });

  tearDown(() {
    final sl = GetIt.instance;
    if (sl.isRegistered<UserArticlesBloc>()) {
      sl.unregister<UserArticlesBloc>();
    }
    if (sl.isRegistered<EditArticleBloc>()) {
      sl.unregister<EditArticleBloc>();
    }
  });

  testWidgets('shows one edit button per article', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MyArticlesPage()),
    );
    // No pumpAndSettle: tile image loads never complete in widget tests,
    // keeping a perpetual animation alive (same reason article_tile_test
    // pumps a single frame).
    await tester.pump();

    expect(find.text('First article'), findsOneWidget);
    expect(find.text('Second article'), findsOneWidget);
    expect(find.byTooltip('Edit article'), findsNWidgets(2));
  });

  testWidgets('tapping edit opens the Update page for that article',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoutes,
        home: const MyArticlesPage(),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Edit article').first);
    // Pump past the push transition without pumpAndSettle (see above).
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Edit Article'), findsOneWidget);
    final fields =
        tester.widgetList<TextFormField>(find.byType(TextFormField)).toList();
    expect(fields, hasLength(2));
    expect(fields[0].controller?.text, 'First article');
    expect(find.text('Delete article'), findsOneWidget);
  });
}
