import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/get_published_articles_use_case.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/entities/publishable_article.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/cubit/published_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/pages/published_article_detail_page.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/pages/published_articles_page.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/widgets/published_article_tile.dart';

import '../../support/fake_read_published_articles_repository.dart';

Widget appWith(PublishedArticlesCubit cubit) {
  return MaterialApp(
    onGenerateRoute: (settings) {
      if (settings.name == '/PublishedArticleDetails') {
        return MaterialPageRoute<void>(
          builder: (_) => PublishedArticleDetailPage(
            article: settings.arguments as PublishableArticle,
          ),
        );
      }
      return null;
    },
    home: BlocProvider<PublishedArticlesCubit>.value(
      value: cubit,
      child: const PublishedArticlesPage(),
    ),
  );
}

void main() {
  testWidgets('shows an empty state', (tester) async {
    final repository = FakeReadPublishedArticlesRepository();
    final cubit = PublishedArticlesCubit(
      GetPublishedArticlesUseCase(repository),
    );
    await cubit.load();

    await tester.pumpWidget(appWith(cubit));

    expect(find.text('No published articles yet.'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('shows failure and retry loads the articles', (tester) async {
    final repository = FakeReadPublishedArticlesRepository()
      ..error = StateError('unavailable');
    final cubit = PublishedArticlesCubit(
      GetPublishedArticlesUseCase(repository),
    );
    await cubit.load();
    await tester.pumpWidget(appWith(cubit));

    expect(find.text('Unable to load published articles.'), findsOneWidget);
    repository
      ..error = null
      ..articles = [publishedArticle()];
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(PublishedArticleTile), findsOneWidget);
    expect(repository.calls, 2);
    await cubit.close();
  });

  testWidgets('opens a detail with every published field', (tester) async {
    final article = publishedArticle();
    final repository = FakeReadPublishedArticlesRepository()
      ..articles = [article];
    final cubit = PublishedArticlesCubit(
      GetPublishedArticlesUseCase(repository),
    );
    await cubit.load();
    await tester.pumpWidget(appWith(cubit));

    expect(find.text(article.title), findsOneWidget);
    expect(find.text(article.description), findsOneWidget);
    expect(find.textContaining(article.author), findsOneWidget);
    await tester.tap(find.byType(PublishedArticleTile));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final detail = find.byType(PublishedArticleDetailPage);
    expect(detail, findsOneWidget);
    expect(
      find.descendant(of: detail, matching: find.text(article.title)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detail, matching: find.text(article.description)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detail, matching: find.text(article.content)),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detail,
        matching: find.textContaining(article.author),
      ),
      findsOneWidget,
    );
    await cubit.close();
  });
}
