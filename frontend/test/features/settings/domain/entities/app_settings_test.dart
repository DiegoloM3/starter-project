import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';

void main() {
  test('text size factors render the 17sp body at 16 / 17 / 19 / 21 sp', () {
    final rendered = TextSizePreference.values.map((t) => (17 * t.factor).round());
    expect(rendered, [16, 17, 19, 21]);
    expect(TextSizePreference.values.map((t) => t.label), ['Small', 'Default', 'Large', 'Largest']);
  });

  test('smaller and larger step through the scale and clamp at the ends', () {
    expect(TextSizePreference.medium.larger, TextSizePreference.large);
    expect(TextSizePreference.medium.smaller, TextSizePreference.small);
    expect(TextSizePreference.small.smaller, TextSizePreference.small);
    expect(TextSizePreference.extraLarge.larger, TextSizePreference.extraLarge);
  });
}
