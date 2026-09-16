import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_theme.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/skeleton/skeleton_box.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('bones take their size and colour from the palette', (tester) async {
    await pumpApp(tester, const Center(child: SkeletonBox(width: 120, height: 16)));

    expect(tester.getSize(find.byType(SkeletonBox)), const Size(120, 16));
    final container = tester.widget<Container>(find.byType(Container));
    expect(container.color, AppPalette.light.skeletonBone);
  });

  testWidgets('SkeletonArea shimmers by default', (tester) async {
    await pumpApp(tester, const SkeletonArea(child: SkeletonBox(height: 16)));

    expect(find.byType(Shimmer), findsOneWidget);
  });

  testWidgets('SkeletonArea stays static when animations are disabled', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: SkeletonArea(child: SkeletonBox(height: 16)),
        ),
      ),
    );

    expect(find.byType(Shimmer), findsNothing);
    final opacity = find.descendant(of: find.byType(SkeletonArea), matching: find.byType(Opacity));
    expect(tester.widget<Opacity>(opacity).opacity, 0.6);
  });
}
