import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/appearance.dart';

void main() {
  test('finds an appearance by its id', () {
    expect(Appearance.fromId('dark'), Appearance.dark);
  });

  test('falls back to the light appearance when the id is unknown or missing', () {
    expect(Appearance.fromId('sepia'), Appearance.light);
    expect(Appearance.fromId(null), Appearance.light);
  });
}
