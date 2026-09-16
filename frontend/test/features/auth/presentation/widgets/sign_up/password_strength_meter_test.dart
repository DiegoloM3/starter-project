import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/sign_up/password_strength_meter.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  Iterable<Color> segmentColours(WidgetTester tester) {
    return tester
        .widgetList<Container>(find.descendant(
          of: find.byType(Row),
          matching: find.byType(Container),
        ))
        .map((c) => (c.decoration as BoxDecoration).color!);
  }

  testWidgets('fills one segment per level in ink', (tester) async {
    await pumpApp(tester, const PasswordStrengthMeter(strength: PasswordStrength.good));

    final colours = segmentColours(tester).toList();
    expect(colours.length, 4);
    expect(colours.take(3), everyElement(AppPalette.light.ink));
    expect(colours.last, AppPalette.light.outline);
    expect(find.textContaining('GOOD PASSWORD.'), findsOneWidget);
  });

  testWidgets('a weak password fills one segment in red', (tester) async {
    await pumpApp(tester, const PasswordStrengthMeter(strength: PasswordStrength.weak));

    final colours = segmentColours(tester).toList();
    expect(colours.first, AppPalette.light.primary);
    expect(colours.skip(1), everyElement(AppPalette.light.outline));
  });
}
