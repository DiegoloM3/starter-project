import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/thumbnail_fallback.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the category initial at 46% of the tile', (tester) async {
    await pumpApp(
      tester,
      const Center(child: ThumbnailFallback(categoryLabel: 'technology', size: 100)),
    );

    final text = tester.widget<Text>(find.text('T'));
    expect(text.style?.fontSize, 46);
    expect(tester.getSize(find.byType(ThumbnailFallback)), const Size(100, 100));
  });

  testWidgets('an empty label falls back to N', (tester) async {
    await pumpApp(
      tester,
      const ThumbnailFallback(categoryLabel: '', size: 96),
    );

    expect(find.text('N'), findsOneWidget);
  });
}
