import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/widgets/community_article_detail_hero_image.dart';

// Pins spec 012 scenario 10: the hero image uses CachedNetworkImage and
// its placeholder / errorWidget builders return the expected fallback
// chrome. Same pattern as article_image_test.dart — we invoke the
// builders directly to avoid the real image pipeline hang in tests.

void main() {
  group('CommunityArticleDetailHeroImage', () {
    testWidgets('uses CachedNetworkImage wired to the provided URL',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommunityArticleDetailHeroImage(
            imageUrl: 'https://example.com/pic.png',
          ),
        ),
      ));

      final cached = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cached.imageUrl, 'https://example.com/pic.png');
      expect(cached.placeholder, isNotNull);
      expect(cached.errorWidget, isNotNull);
    });

    testWidgets('placeholder builder returns a CircularProgressIndicator',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommunityArticleDetailHeroImage(
            imageUrl: 'https://example.com/pic.png',
          ),
        ),
      ));

      final cached = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      final BuildContext context =
          tester.element(find.byType(CachedNetworkImage));
      final placeholder = cached.placeholder!(context, 'https://example.com/pic.png');

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: placeholder)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('errorWidget builder returns Icons.broken_image_outlined',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommunityArticleDetailHeroImage(
            imageUrl: 'https://example.com/pic.png',
          ),
        ),
      ));

      final cached = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      final BuildContext context =
          tester.element(find.byType(CachedNetworkImage));
      final errorChild = cached.errorWidget!(
        context,
        'https://example.com/pic.png',
        Exception('simulated failure'),
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: errorChild)));
      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    });
  });
}
