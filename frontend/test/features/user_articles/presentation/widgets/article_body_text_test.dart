import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/article_body_text.dart';

void main() {
  testWidgets('a bullet line shows a bullet mark, not its raw "- " marker',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ArticleBodyText(content: '- Milk')),
    ));

    expect(find.text('•'), findsOneWidget);
    expect(find.text('Milk'), findsOneWidget);
    expect(find.textContaining('- Milk'), findsNothing);
  });

  testWidgets(
      'numbered lines are renumbered 1, 2, 3 when shown, even if what was '
      'typed has a gap in it (an earlier item deleted by hand)',
      (tester) async {
    // As stored, these read 1 and 3 -- item 2 was deleted after both were
    // written, and nothing renumbers stored text on its own (see
    // toggleNumberedList). The reader should still see 1, 2 -- a resequenced
    // display, not the stale digits.
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ArticleBodyText(content: '1. First\n3. Third')),
    ));

    expect(find.text('1.'), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
    expect(find.text('3.'), findsNothing);
  });

  testWidgets('a break in the run (a plain line) restarts the count at 1',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ArticleBodyText(content: '1. First\nA plain line\n1. Next run'),
      ),
    ));

    expect(find.text('1.'), findsNWidgets(2));
    expect(find.text('2.'), findsNothing);
  });

  testWidgets('a quote line renders in italics', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ArticleBodyText(content: '> Stay calm')),
    ));

    final text = tester.widget<Text>(find.text('Stay calm'));
    expect(text.style?.fontStyle, FontStyle.italic);
  });
}
