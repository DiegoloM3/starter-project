import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/news/presentation/widgets/article_author_row.dart';

void main() {
  Widget buildRow() {
    return const MaterialApp(
      home: Scaffold(
        body: ArticleAuthorRow(
          authorId: null,
          authorDisplayName: 'Jane Doe',
        ),
      ),
    );
  }

  testWidgets('shows display name without resolving avatar when id is null',
      (tester) async {
    await tester.pumpWidget(buildRow());

    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('shows fallback text when name is missing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ArticleAuthorRow(),
        ),
      ),
    );

    expect(find.text('Unknown author'), findsOneWidget);
  });

  testWidgets(
      'degrades to silhouette when an id has no cubit wired (regression)',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ArticleAuthorRow(
            authorId: 'user-123',
            authorDisplayName: 'Jane Doe',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
