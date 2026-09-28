import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/create/create_article_bloc.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/news/presentation/pages/create_article/create_article_page.dart';

class MockCreateArticleBloc
    extends MockBloc<CreateArticleEvent, CreateArticleState>
    implements CreateArticleBloc {
  final List<CreateArticleEvent> addedEvents = [];

  @override
  void add(CreateArticleEvent event) {
    addedEvents.add(event);
    super.add(event);
  }
}

class MockLocalArticleBloc
    extends MockBloc<LocalArticlesEvent, LocalArticlesState>
    implements LocalArticleBloc {}

void main() {
  late MockCreateArticleBloc mockCreateArticleBloc;

  setUp(() {
    mockCreateArticleBloc = MockCreateArticleBloc();

    if (GetIt.instance.isRegistered<CreateArticleBloc>()) {
      GetIt.instance.unregister<CreateArticleBloc>();
    }
    GetIt.instance.registerFactory<CreateArticleBloc>(() => mockCreateArticleBloc);
  });

  tearDown(() {
    if (GetIt.instance.isRegistered<CreateArticleBloc>()) {
      GetIt.instance.unregister<CreateArticleBloc>();
    }
  });

  Widget buildTestableWidget({Widget? child}) {
    return MaterialApp(
      home: child ?? const CreateArticlePage(),
    );
  }

  testWidgets('renders all initial UI elements properly', (tester) async {
    whenListen(
      mockCreateArticleBloc,
      const Stream<CreateArticleState>.empty(),
      initialState: const CreateArticleIdle(),
    );

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text('New Article'), findsOneWidget);
    expect(find.text('Publish'), findsOneWidget);
    expect(find.text('TITLE'), findsOneWidget);
    expect(find.text('THUMBNAIL'), findsOneWidget);
    expect(find.text('CONTENT'), findsOneWidget);
    expect(find.text('Write your headline...'), findsOneWidget);
    expect(find.text('Tell your story...'), findsOneWidget);
    expect(find.text('Tap to add a thumbnail'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
    expect(
      find.text('Styling with markdown is supported.'),
      findsOneWidget,
    );
  });

  testWidgets('tapping Preview opens the article preview', (tester) async {
    whenListen(
      mockCreateArticleBloc,
      const Stream<CreateArticleState>.empty(),
      initialState: const CreateArticleIdle(),
    );
    final mockLocalArticleBloc = MockLocalArticleBloc();
    whenListen(
      mockLocalArticleBloc,
      const Stream<LocalArticlesState>.empty(),
      initialState: const LocalArticlesLoading(),
    );
    GetIt.instance
        .registerFactory<LocalArticleBloc>(() => mockLocalArticleBloc);
    addTearDown(() {
      if (GetIt.instance.isRegistered<LocalArticleBloc>()) {
        GetIt.instance.unregister<LocalArticleBloc>();
      }
    });

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Write your headline...'),
      'Draft title',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tell your story...'),
      '# Hello preview',
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Preview'));
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    // Preview reuses the detail view in read-only mode: markdown is
    // rendered and the save bookmark is hidden.
    expect(find.byType(ArticleDetailsView), findsOneWidget);
    expect(find.text('Draft title'), findsOneWidget);
    expect(find.byType(GptMarkdown), findsOneWidget);
    expect(find.textContaining('Hello', findRichText: true), findsWidgets);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('shows validation errors when publishing with empty fields',
      (tester) async {
    whenListen(
      mockCreateArticleBloc,
      const Stream<CreateArticleState>.empty(),
      initialState: const CreateArticleIdle(),
    );

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Tap Publish with empty title and content
    await tester.tap(find.text('Publish'));
    await tester.pumpAndSettle();

    expect(find.text('Title is required.'), findsOneWidget);
    expect(find.text('Content is required.'), findsOneWidget);

    // Verify PublishArticle was never added
    expect(mockCreateArticleBloc.addedEvents, isEmpty);
  });

  testWidgets('dispatches PublishArticle when title and content are valid',
      (tester) async {
    whenListen(
      mockCreateArticleBloc,
      const Stream<CreateArticleState>.empty(),
      initialState: const CreateArticleIdle(),
    );

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Fill in title
    final titleField = find.widgetWithText(TextFormField, 'Write your headline...');
    await tester.enterText(titleField, 'Breaking News');

    // Fill in content
    final contentField = find.widgetWithText(TextFormField, 'Tell your story...');
    await tester.enterText(contentField, 'Detailed article content here.');

    await tester.pumpAndSettle();

    // Tap Publish
    await tester.tap(find.text('Publish'));
    await tester.pumpAndSettle();

    final publishedEvents = mockCreateArticleBloc.addedEvents
        .whereType<PublishArticle>()
        .toList();
    expect(publishedEvents.length, 1);
    expect(publishedEvents.first.title, 'Breaking News');
    expect(publishedEvents.first.content, 'Detailed article content here.');
    expect(publishedEvents.first.imageFile, isNull);
  });

  testWidgets('shows loading indicator and hides Publish button in loading state',
      (tester) async {
    whenListen(
      mockCreateArticleBloc,
      const Stream<CreateArticleState>.empty(),
      initialState: const CreateArticleLoading(),
    );

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();

    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    expect(find.text('Publish'), findsNothing);
  });

  testWidgets('shows SnackBar and adds ResetCreateArticle on CreateArticleError',
      (tester) async {
    final streamController = StreamController<CreateArticleState>.broadcast();

    whenListen(
      mockCreateArticleBloc,
      streamController.stream,
      initialState: const CreateArticleIdle(),
    );

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    streamController.add(const CreateArticleError('Something failed'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Something failed'), findsOneWidget);

    expect(
      mockCreateArticleBloc.addedEvents,
      contains(const ResetCreateArticle()),
    );

    await streamController.close();
  });

  testWidgets('shows SnackBar and pops Navigator on CreateArticleSuccess',
      (tester) async {
    final streamController = StreamController<CreateArticleState>.broadcast();

    whenListen(
      mockCreateArticleBloc,
      streamController.stream,
      initialState: const CreateArticleIdle(),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateArticlePage()),
            ),
            child: const Text('Open Page'),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Open CreateArticlePage
    await tester.tap(find.text('Open Page'));
    await tester.pumpAndSettle();
    expect(find.text('New Article'), findsOneWidget);

    // Emit success
    streamController.add(const CreateArticleSuccess());
    await tester.pump();
    await tester.pumpAndSettle();

    // Page should have popped, returning to previous screen
    expect(find.text('Open Page'), findsOneWidget);
    expect(find.text('Article published successfully!'), findsOneWidget);

    await streamController.close();
  });

  testWidgets('pops page when back button is pressed', (tester) async {
    whenListen(
      mockCreateArticleBloc,
      const Stream<CreateArticleState>.empty(),
      initialState: const CreateArticleIdle(),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateArticlePage()),
            ),
            child: const Text('Open Page'),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Page'));
    await tester.pumpAndSettle();
    expect(find.text('New Article'), findsOneWidget);

    // Tap back icon (leading of AppBar)
    await tester.tap(find.byIcon(Ionicons.chevronBack));
    await tester.pumpAndSettle();

    expect(find.text('Open Page'), findsOneWidget);
    expect(find.text('New Article'), findsNothing);
  });
}
