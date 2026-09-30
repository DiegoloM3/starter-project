import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/publish_article_button.dart';

import '../../../../helpers/localized_app.dart';

void main() {
  testWidgets('publishes when tapped', (tester) async {
    var presses = 0;
    await tester.pumpWidget(localizedApp(
      home: Scaffold(body: PublishArticleButton(isPublishing: false, onPressed: () => presses++)),
    ));

    await tester.tap(find.text('Publish Article'));

    expect(presses, 1);
  });

  testWidgets('shows the progress and ignores taps while publishing', (tester) async {
    var presses = 0;
    await tester.pumpWidget(localizedApp(
      home: Scaffold(body: PublishArticleButton(isPublishing: true, onPressed: () => presses++)),
    ));

    await tester.tap(find.text('Publishing…'));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(presses, 0);
  });
}
