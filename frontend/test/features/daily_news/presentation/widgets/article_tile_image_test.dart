import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile_image.dart';

// Regression test for spec 009 v1.1.2. When NewsAPI returns urlToImage: null,
// the tile widget used to force-unwrap the field and crash the whole feed on
// scroll (_TypeError: Null check operator used on a null value). The fix is
// a short-circuit that renders the broken_image placeholder without ever
// constructing a CachedNetworkImage.

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets(
    'renders the placeholder directly when imageUrl is null',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const SizedBox(
          height: 180,
          width: 180,
          child: ArticleTileImage(imageUrl: null),
        )),
      );

      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    },
  );

  testWidgets(
    'renders the placeholder directly when imageUrl is empty',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const SizedBox(
          height: 180,
          width: 180,
          child: ArticleTileImage(imageUrl: ''),
        )),
      );

      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    },
  );

  testWidgets(
    'constructs a CachedNetworkImage when imageUrl is provided',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const SizedBox(
          height: 180,
          width: 180,
          child: ArticleTileImage(imageUrl: 'https://example.com/a.jpg'),
        )),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    },
  );
}
