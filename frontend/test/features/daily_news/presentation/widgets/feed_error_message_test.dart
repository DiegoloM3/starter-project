import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed_error_message.dart';

void main() {
  group('FeedErrorMessage', () {
    testWidgets('lets the reader retry loading the feed', (tester) async {
      var retries = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: FeedErrorMessage(onRetryPressed: () => retries++)),
      ));

      await tester.tap(find.text('Retry'));

      expect(retries, 1);
    });
  });
}
