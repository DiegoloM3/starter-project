import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/news/presentation/pages/saved_article/saved_article.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class _FakeLocalBloc extends Fake implements LocalArticleBloc {
  @override
  LocalArticlesState state;

  final added = <LocalArticlesEvent>[];

  _FakeLocalBloc(this.state);

  @override
  Stream<LocalArticlesState> get stream =>
      Stream<LocalArticlesState>.value(state);

  @override
  void add(LocalArticlesEvent event) => added.add(event);

  @override
  Future<void> close() async {}
}

void main() {
  late _FakeLocalBloc fakeBloc;

  Widget buildPage(LocalArticlesState state) {
    fakeBloc = _FakeLocalBloc(state);
    sl.registerFactory<LocalArticleBloc>(() => fakeBloc);
    return const MaterialApp(home: SavedArticles());
  }

  tearDown(() async {
    await sl.reset();
  });

  testWidgets(
      'shows an explanatory error with retry instead of a blank page '
      '(regression: failed load looked like everything was deleted)',
      (tester) async {
    await tester.pumpWidget(
      buildPage(const LocalArticlesError('db locked')),
    );
    await tester.pump();

    expect(find.text('Could not load your saved articles.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    // NB: SavedArticles dispatches one initial GetSavedArticles when its
    // bloc is created, so the Retry tap brings the total to two.
    expect(
      fakeBloc.added.whereType<GetSavedArticles>().length,
      2,
    );
  });

  testWidgets('shows the empty state when nothing is saved', (tester) async {
    await tester.pumpWidget(
      buildPage(const LocalArticlesDone([])),
    );
    await tester.pump();

    expect(find.text('NO SAVED ARTICLES'), findsOneWidget);
  });
}
