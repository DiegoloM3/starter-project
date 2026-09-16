import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/brand_mark.dart';

import '../../../../helpers/pump_app.dart';

/// A bundle with nothing in it, to see what the mark does without its asset.
class _EmptyBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async => throw FlutterError('no asset: $key');
}

void main() {
  testWidgets('shows the brand asset at the requested size, labelled for screen readers', (tester) async {
    await pumpApp(tester, const BrandMark(size: 40));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.semanticLabel, 'Headline News');
    expect(tester.getSize(find.byType(BrandMark)), const Size(40, 40));
  });

  testWidgets('falls back to an H block when the asset cannot be loaded', (tester) async {
    await pumpApp(tester, DefaultAssetBundle(bundle: _EmptyBundle(), child: const BrandMark(size: 40)));
    await tester.pump();
    await tester.pump();

    expect(find.text('H'), findsOneWidget);
    expect(tester.getSize(find.text('H').first), isNot(Size.zero));
  });
}
