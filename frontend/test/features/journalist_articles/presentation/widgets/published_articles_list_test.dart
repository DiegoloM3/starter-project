import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/published_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_published_articles.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/published_articles/published_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/published_articles_list.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/localized_app.dart';

class MockGetPublishedArticlesUseCase extends Mock implements GetPublishedArticlesUseCase {}

final article = PublishedArticleEntity(
  id: 'article-1',
  title: 'Neighbours turn an empty lot into a garden',
  content: 'From concrete to tomatoes.',
  description: 'From concrete to tomatoes.',
  author: 'Local Desk',
  thumbnailUrl: 'https://example.com/garden.png',
  publishedAt: DateTime.utc(2026, 9, 28, 12),
);

void main() {
  late MockGetPublishedArticlesUseCase getArticles;
  late List<PublishedArticleEntity> pressedArticles;
  late int publishPresses;

  setUp(() {
    getArticles = MockGetPublishedArticlesUseCase();
    pressedArticles = [];
    publishPresses = 0;
  });

  void givenArticles(DataState<List<PublishedArticleEntity>> result) {
    when(() => getArticles(params: any(named: 'params'))).thenAnswer((_) async => result);
  }

  Widget list() {
    return Scaffold(
      body: BlocProvider(
        create: (_) => PublishedArticlesCubit(getArticles)..loadArticles(),
        child: PublishedArticlesList(onArticlePressed: pressedArticles.add, onPublishPressed: () => publishPresses++),
      ),
    );
  }

  Future<void> showList(WidgetTester tester) async {
    await tester.pumpWidget(localizedApp(home: list()));
    await pumpFrames(tester);
  }

  testWidgets('shows a loading indicator while the articles load', (tester) async {
    when(() => getArticles(params: any(named: 'params'))).thenAnswer(
      (_) => Future.delayed(const Duration(seconds: 1), () => DataSuccess([article])),
    );

    await tester.pumpWidget(localizedApp(home: list()));

    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('shows the articles and reports the one tapped', (tester) async {
    givenArticles(DataSuccess([article]));
    await showList(tester);

    await tester.tap(find.text('Neighbours turn an empty lot into a garden'));

    expect(pressedArticles, [article]);
  });

  testWidgets('invites the journalist to write the first article when there are none', (tester) async {
    givenArticles(const DataSuccess([]));
    await showList(tester);

    await tester.tap(find.text('Write an article'));

    expect(find.textContaining('No articles yet'), findsOneWidget);
    expect(publishPresses, 1);
  });

  testWidgets('offers to try again when the articles cannot be loaded', (tester) async {
    givenArticles(DataFailed(Exception('offline')));
    await showList(tester);
    expect(find.text('The articles could not be loaded.'), findsOneWidget);
    givenArticles(DataSuccess([article]));

    await tester.tap(find.text('Try again'));
    await pumpFrames(tester);

    expect(find.text('Neighbours turn an empty lot into a garden'), findsOneWidget);
  });

  group('accessibility', () {
    // No contrast check with articles: their thumbnails are network images (see expectAccessible).
    testWidgets('has usable, labeled buttons', (tester) async {
      givenArticles(DataSuccess([article]));
      await showInEveryAppearance(tester, list());

      await expectUsableTapTargets(tester);
    }, variant: appearances);

    testWidgets('fits with the text at 200 %', (tester) async {
      givenArticles(DataSuccess([article]));
      await showInEveryAppearance(tester, list(), textScale: 2);

      expect(tester.takeException(), isNull);
    }, variant: appearances);

    testWidgets('meets the guidelines when there are no articles yet', (tester) async {
      givenArticles(const DataSuccess([]));
      await showInEveryAppearance(tester, list());

      await expectAccessible(tester);
    }, variant: appearances);

    testWidgets('meets the guidelines when the articles cannot be loaded', (tester) async {
      givenArticles(DataFailed(Exception('offline')));
      await showInEveryAppearance(tester, list());

      await expectAccessible(tester);
    }, variant: appearances);
  });
}
