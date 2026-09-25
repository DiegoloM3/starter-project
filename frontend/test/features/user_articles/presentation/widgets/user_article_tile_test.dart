import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/user_article_tile.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

void main() {
  UserArticleEntity article({required bool isDraft, String title = ''}) {
    return UserArticleEntity(
      id: 'a1',
      authorId: 'u1',
      authorName: 'Ana',
      title: title,
      description: 'A description.',
      content: 'x' * 60,
      thumbnailURL: '',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      isDraft: isDraft,
    );
  }

  Future<void> pumpTile(WidgetTester tester, UserArticleEntity article) async {
    await tester.pumpWidget(MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: UserArticleTile(article: article, onTap: () {}),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('a draft is badged, a published article is not', (tester) async {
    await pumpTile(tester, article(isDraft: true, title: 'Working title'));

    expect(find.text('DRAFT'), findsOneWidget);
  });

  testWidgets('a published article carries no draft badge', (tester) async {
    await pumpTile(tester, article(isDraft: false, title: 'A real title'));

    expect(find.text('DRAFT'), findsNothing);
  });

  testWidgets('an untitled draft shows a placeholder instead of blank space',
      (tester) async {
    await pumpTile(tester, article(isDraft: true, title: ''));

    expect(find.text('Untitled draft'), findsOneWidget);
  });

  testWidgets('the footer shows when it was last edited and the reading time',
      (tester) async {
    await pumpTile(tester, article(isDraft: false, title: 'A real title'));

    expect(find.text('Jan 1, 2026'), findsOneWidget);
    expect(find.text('1 min read'), findsOneWidget);
  });
}
