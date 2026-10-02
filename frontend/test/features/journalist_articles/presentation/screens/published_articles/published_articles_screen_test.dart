import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/theme/app_skeletons.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_published_articles.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/published_articles/published_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/screens/published_articles/published_articles_screen.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/journalist_article_tile.dart';

class MockGetPublishedArticlesUseCase extends Mock implements GetPublishedArticlesUseCase {}

void main() {
  late MockGetPublishedArticlesUseCase getPublishedArticles;
  late PublishedArticlesCubit cubit;

  final articles = [
    JournalistArticleEntity(
      id: 'article1',
      title: 'Published from the Android emulator',
      description: 'End-to-end test of the data layer.',
      content: 'This article was written in the app.',
      author: 'Jane Doe',
      authorId: 'janeDoeUid',
      thumbnailURL: '',
      publishedAt: DateTime.utc(2026, 10, 1),
      commentCount: 3,
    ),
  ];

  setUp(() {
    getPublishedArticles = MockGetPublishedArticlesUseCase();
    cubit = PublishedArticlesCubit(getPublishedArticles);
  });

  tearDown(() => cubit.close());

  Future<void> showPublishedArticles(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme(),
      home: Scaffold(
        body: BlocProvider.value(value: cubit, child: const PublishedArticlesScreen()),
      ),
    ));
  }

  testWidgets('shows a skeleton of the list while the articles are loading', (tester) async {
    when(() => getPublishedArticles()).thenAnswer((_) => Completer<DataState<List<JournalistArticleEntity>>>().future);

    await showPublishedArticles(tester);
    unawaited(cubit.loadArticles());
    await tester.pump();

    expect(find.byType(AppSkeletonizer), findsOneWidget);
    expect(find.byType(JournalistArticleTile), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('replaces the skeleton with the articles once they are loaded', (tester) async {
    when(() => getPublishedArticles()).thenAnswer((_) async => DataSuccess(articles));

    await showPublishedArticles(tester);
    await cubit.loadArticles();
    await tester.pump();

    expect(find.byType(AppSkeletonizer), findsNothing);
    expect(find.text('Published from the Android emulator'), findsOneWidget);
  });

  testWidgets('shows how many comments each article has', (tester) async {
    when(() => getPublishedArticles()).thenAnswer((_) async => DataSuccess(articles));

    await showPublishedArticles(tester);
    await cubit.loadArticles();
    await tester.pump();

    // The tile reads all its texts as one label, so the comments are part of it.
    expect(find.bySemanticsLabel(RegExp('3 comments')), findsOneWidget);
  });
}
