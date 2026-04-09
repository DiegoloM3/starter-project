import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_image.dart';

// Widget tests for ArticleImage. Pins spec 009:
// - The widget uses CachedNetworkImage (not raw Image.network), so the
//   "Invalid image data" exception from a non-image URL is caught and
//   routed to errorWidget.
// - The placeholder builder renders a CupertinoActivityIndicator
//   (Scenario 3).
// - The errorWidget builder renders Icons.broken_image_outlined
//   (Scenario 2 — the bug that prompted this spec).
//
// We inspect the builder callbacks on the CachedNetworkImage widget directly
// rather than waiting for the real network loader to complete, because the
// Flutter test HttpClient stubs network requests in a way that makes
// CachedNetworkImage's retry/decode pipeline hang pumpAndSettle. Testing the
// builders is deterministic and exercises the same code paths the bug hit.

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  const sampleUrl = 'https://example.invalid/not-a-real-image.jpg';

  testWidgets(
    'uses CachedNetworkImage instead of raw Image.network',
    (tester) async {
      await tester.pumpWidget(_wrap(const ArticleImage(imageUrl: sampleUrl)));

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    },
  );

  // Spec 009 v1.1.0: when NewsAPI returns urlToImage: null, the widget must
  // short-circuit to the placeholder without constructing a
  // CachedNetworkImage — that is how we eliminate the log noise from
  // attempting to decode a junk URL.
  testWidgets(
    'renders the placeholder directly when imageUrl is null',
    (tester) async {
      await tester.pumpWidget(_wrap(const ArticleImage(imageUrl: null)));

      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    },
  );

  testWidgets(
    'renders the placeholder directly when imageUrl is empty',
    (tester) async {
      await tester.pumpWidget(_wrap(const ArticleImage(imageUrl: '')));

      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    },
  );

  testWidgets(
    'placeholder builder shows a CupertinoActivityIndicator',
    (tester) async {
      await tester.pumpWidget(_wrap(const ArticleImage(imageUrl: sampleUrl)));

      final cached = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      final BuildContext context = tester.element(find.byType(CachedNetworkImage));
      final placeholderWidget = cached.placeholder!(context, sampleUrl);

      await tester.pumpWidget(_wrap(placeholderWidget));

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
    },
  );

  testWidgets(
    'errorWidget builder shows Icons.broken_image_outlined',
    (tester) async {
      await tester.pumpWidget(_wrap(const ArticleImage(imageUrl: sampleUrl)));

      final cached = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      final BuildContext context = tester.element(find.byType(CachedNetworkImage));
      final errorWidget = cached.errorWidget!(
        context,
        sampleUrl,
        Exception('Invalid image data'),
      );

      await tester.pumpWidget(_wrap(errorWidget));

      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    },
  );
}
