import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/presentation/widgets/app_image.dart';
import 'package:news_app_clean_architecture/core/presentation/widgets/brand_mark.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

void main() {
  const url = 'https://example.com/photo.jpg';

  testWidgets('online, attempts to load the photo over the network',
      (tester) async {
    await tester.pumpWidget(_app(const AppImage(url: url)));

    expect(find.byType(CachedNetworkImage), findsOneWidget);
    // The drawing-itself mark while a fetch is in flight, not the still
    // one -- that's only for when there's truly no photo.
    expect(find.byType(AnimatedBrandMark), findsOneWidget);
    // Still loading, not yet known to have no photo -- no label yet.
    expect(find.text('No photo'), findsNothing);
  });

  testWidgets(
      'offline, never attempts the network -- straight to the placeholder',
      (tester) async {
    await tester.pumpWidget(_app(const AppImage(url: url, isOffline: true)));

    // The regression this guards against: every offline row used to try
    // and fail a real network fetch as it scrolled into view, often several
    // at once, which is what caused the reported stutter.
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byType(BrandMark), findsOneWidget);
    expect(find.byType(AnimatedBrandMark), findsNothing);
  });

  testWidgets('offline with no url, still just shows the placeholder',
      (tester) async {
    await tester.pumpWidget(_app(const AppImage(url: null, isOffline: true)));

    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byType(BrandMark), findsOneWidget);
  });

  testWidgets('no photo at all says so, under the mark, not just a blank N',
      (tester) async {
    await tester.pumpWidget(_app(const AppImage(url: null)));

    expect(find.byType(BrandMark), findsOneWidget);
    expect(find.text('No photo'), findsOneWidget);
  });
}

Widget _app(Widget child) => MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    );
