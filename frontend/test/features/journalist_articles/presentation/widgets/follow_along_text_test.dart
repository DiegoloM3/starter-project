import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_narration.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_narration_progress.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/follow_along_text.dart';

import '../../../../helpers/localized_app.dart';
import '../../../../helpers/accessibility.dart';

const narration = ArticleNarrationEntity(
  parts: [
    NarrationPart(NarrationPartKind.title, ['Title']),
    NarrationPart(NarrationPartKind.byline, ['Written by Me']),
    NarrationPart(NarrationPartKind.heading, ['How it works']),
    NarrationPart(NarrationPartKind.numberedItem, ['Tap the button.']),
    NarrationPart(NarrationPartKind.numberedItem, ['Write your story.']),
    NarrationPart(NarrationPartKind.paragraph, ['Then share it.', 'That is all.']),
    NarrationPart(NarrationPartKind.bulletedItem, ['A tip.']),
  ],
  languageTag: 'en-US',
);

void main() {
  Future<void> showReading(WidgetTester tester, int sentenceIndex) {
    return tester.pumpWidget(localizedApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: FollowAlongText(
            progress: ArticleNarrationProgressEntity(narration: narration, sentenceIndex: sentenceIndex),
          ),
        ),
      ),
    ));
  }

  List<String> highlightedSentences(WidgetTester tester) {
    final highlighted = <String>[];
    for (final text in tester.widgetList<RichText>(find.byType(RichText))) {
      text.text.visitChildren((span) {
        final isHighlighted = span.style?.backgroundColor == readAloudHighlightColor;
        if (isHighlighted && span is TextSpan) highlighted.add(span.text!);
        return true;
      });
    }
    return highlighted;
  }

  testWidgets('shows the content, but not the title and byline already shown above it', (tester) async {
    await showReading(tester, 0);

    expect(find.text('How it works'), findsOneWidget);
    expect(find.text('Then share it. That is all.'), findsOneWidget);
    expect(find.text('Title'), findsNothing);
    expect(find.text('Written by Me'), findsNothing);
  });

  testWidgets('keeps the numbers and bullets of the lists', (tester) async {
    await showReading(tester, 0);

    expect(find.text('1.'), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
    expect(find.text('•'), findsOneWidget);
  });

  testWidgets('highlights only the sentence being read, even inside a paragraph', (tester) async {
    await showReading(tester, 6);

    expect(highlightedSentences(tester), ['That is all.']);
  });

  testWidgets('keeps the sentence being read readable in every appearance', (tester) async {
    await showInEveryAppearance(
      tester,
      const Scaffold(
        body: FollowAlongText(progress: ArticleNarrationProgressEntity(narration: narration, sentenceIndex: 6)),
      ),
    );

    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }, variant: appearances);
}
