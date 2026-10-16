import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/publication_date_text.dart';

void main() {
  final now = DateTime(2026, 10, 15, 12);

  String describeTimeSince(Duration elapsedTime) {
    return PublicationDateText.describeTimeSince(now.subtract(elapsedTime), now);
  }

  group('PublicationDateText.describeTimeSince', () {
    test('describes an article published less than a minute ago', () {
      expect(describeTimeSince(const Duration(seconds: 30)), 'Just now');
    });

    test('does not show a negative time for a date in the future', () {
      expect(describeTimeSince(const Duration(minutes: -5)), 'Just now');
    });

    test('describes the minutes since the publication', () {
      expect(describeTimeSince(const Duration(minutes: 1)), '1 minute ago');
      expect(describeTimeSince(const Duration(minutes: 45)), '45 minutes ago');
    });

    test('describes the hours since the publication', () {
      expect(describeTimeSince(const Duration(hours: 1)), '1 hour ago');
      expect(describeTimeSince(const Duration(hours: 2, minutes: 59)), '2 hours ago');
    });

    test('describes the days since the publication', () {
      expect(describeTimeSince(const Duration(days: 1)), '1 day ago');
      expect(describeTimeSince(const Duration(days: 6)), '6 days ago');
    });

    test('shows the date of an article published more than a week ago', () {
      expect(PublicationDateText.describeTimeSince(DateTime(2026, 10, 1, 12), now), 'Oct 1, 2026');
    });
  });

  group('PublicationDateText', () {
    testWidgets('shows how long ago the article was published', (tester) async {
      final publicationDate = DateTime.now().subtract(const Duration(hours: 2, minutes: 5));

      await tester.pumpWidget(MaterialApp(home: PublicationDateText(publicationDate: publicationDate)));

      expect(find.text('2 hours ago'), findsOneWidget);
    });
  });
}
