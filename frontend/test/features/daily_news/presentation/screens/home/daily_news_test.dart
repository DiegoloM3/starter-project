import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_news_feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home/daily_news.dart';

class MockGetNewsFeedUseCase extends Mock implements GetNewsFeedUseCase {}

void main() {
  late MockGetNewsFeedUseCase getNewsFeed;

  setUp(() => getNewsFeed = MockGetNewsFeedUseCase());

  Future<void> pumpFeed(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: BlocProvider(
        create: (_) => RemoteArticlesBloc(getNewsFeed)..add(const GetArticles()),
        child: const DailyNews(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  group('DailyNews', () {
    testWidgets('shows the articles of the news feed', (tester) async {
      when(() => getNewsFeed()).thenAnswer(
        (_) async => const DataSuccess([ArticleEntity(title: 'Breaking News!')]),
      );

      await pumpFeed(tester);

      expect(find.text('Breaking News!'), findsOneWidget);
    });

    testWidgets('loads the feed again when the reader retries after an error', (tester) async {
      when(() => getNewsFeed()).thenAnswer((_) async => DataFailed(Exception('No connection')));
      await pumpFeed(tester);
      when(() => getNewsFeed()).thenAnswer(
        (_) async => const DataSuccess([ArticleEntity(title: 'Breaking News!')]),
      );

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsNothing);
      expect(find.text('Breaking News!'), findsOneWidget);
    });

    testWidgets('shows the new articles when the reader pulls to refresh', (tester) async {
      when(() => getNewsFeed()).thenAnswer(
        (_) async => const DataSuccess([ArticleEntity(title: 'Breaking News!')]),
      );
      await pumpFeed(tester);
      when(() => getNewsFeed()).thenAnswer(
        (_) async => const DataSuccess([ArticleEntity(title: 'Latest news'), ArticleEntity(title: 'Breaking News!')]),
      );

      await tester.fling(find.text('Breaking News!'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Latest news'), findsOneWidget);
      verify(() => getNewsFeed()).called(2);
    });
  });
}
