import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/edit/edit_article_bloc.dart';
import 'package:news_app_clean_architecture/features/news/presentation/pages/edit_article/edit_article_page.dart';

class MockEditArticleBloc
    extends MockBloc<EditArticleEvent, EditArticleState>
    implements EditArticleBloc {
  final List<EditArticleEvent> addedEvents = [];

  @override
  void add(EditArticleEvent event) {
    addedEvents.add(event);
    super.add(event);
  }
}

void main() {
  late MockEditArticleBloc mockEditArticleBloc;

  const tArticle = ArticleEntity(
    id: 'art-1',
    authorDisplayName: 'Jane',
    title: 'Old title',
    publishedAt: '2026-09-27T00:00:00Z',
    content: 'Old content',
    authorId: 'user-123',
  );

  setUp(() {
    mockEditArticleBloc = MockEditArticleBloc();

    if (GetIt.instance.isRegistered<EditArticleBloc>()) {
      GetIt.instance.unregister<EditArticleBloc>();
    }
    GetIt.instance.registerFactory<EditArticleBloc>(() => mockEditArticleBloc);
  });

  tearDown(() {
    if (GetIt.instance.isRegistered<EditArticleBloc>()) {
      GetIt.instance.unregister<EditArticleBloc>();
    }
  });

  Widget buildTestableWidget() {
    return const MaterialApp(
      home: EditArticlePage(article: tArticle),
    );
  }

  void stubIdle() {
    whenListen(
      mockEditArticleBloc,
      const Stream<EditArticleState>.empty(),
      initialState: const EditArticleIdle(),
    );
  }

  testWidgets('renders prefilled form and delete section', (tester) async {
    stubIdle();

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text('Edit Article'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Delete article'), findsOneWidget);
    final fields =
        tester.widgetList<TextFormField>(find.byType(TextFormField)).toList();
    expect(fields, hasLength(2));
    expect(fields[0].controller?.text, 'Old title');
    expect(fields[1].controller?.text, 'Old content');
  });

  testWidgets('tapping Save dispatches SaveArticleEdits', (tester) async {
    stubIdle();

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(mockEditArticleBloc.addedEvents, hasLength(1));
    final event =
        mockEditArticleBloc.addedEvents.single as SaveArticleEdits;
    expect(event.original, tArticle);
    expect(event.title, 'Old title');
    expect(event.content, 'Old content');
  });

  testWidgets('tapping Save with an empty title dispatches nothing',
      (tester) async {
    stubIdle();

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      '   ',
    );
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(mockEditArticleBloc.addedEvents, isEmpty);
    expect(find.text('Title is required.'), findsOneWidget);
  });

  testWidgets('confirming the delete dialog dispatches DeleteArticleRequested',
      (tester) async {
    stubIdle();

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Delete article'));
    await tester.tap(find.text('Delete article'));
    await tester.pumpAndSettle();

    expect(find.text('Delete article?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(mockEditArticleBloc.addedEvents, hasLength(1));
    final event = mockEditArticleBloc.addedEvents.single
        as DeleteArticleRequested;
    expect(event.article, tArticle);
  });

  testWidgets('cancelling the delete dialog dispatches nothing',
      (tester) async {
    stubIdle();

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Delete article'));
    await tester.tap(find.text('Delete article'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(mockEditArticleBloc.addedEvents, isEmpty);
  });
}
