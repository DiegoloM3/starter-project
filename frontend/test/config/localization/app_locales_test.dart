import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/localization/app_locales.dart';

/// Decision #59: Spanish on a Spanish device, English everywhere else.
void main() {
  const supported = [AppLocales.english, AppLocales.spanish];

  Locale resolve(List<Locale>? preferred) =>
      AppLocales.resolve(preferred, supported);

  test('a Spanish device gets Spanish', () {
    expect(resolve([const Locale('es')]), AppLocales.spanish);
  });

  test('a Spanish device gets Spanish whatever the region', () {
    expect(resolve([const Locale('es', 'MX')]), AppLocales.spanish);
    expect(resolve([const Locale('es', 'AR')]), AppLocales.spanish);
  });

  test('an English device gets English', () {
    expect(resolve([const Locale('en', 'GB')]), AppLocales.english);
  });

  test('a language the app does not speak falls back to English', () {
    expect(resolve([const Locale('fr')]), AppLocales.english);
    expect(resolve([const Locale('de')]), AppLocales.english);
    expect(resolve([const Locale('ja')]), AppLocales.english);
  });

  /// The bug this rule was written for. Android hands over an ordered list of
  /// every language the person has configured, and Flutter's own resolution
  /// walks it looking for a match — so a phone switched to French, with
  /// Spanish left further down the list, kept running in Spanish. Only the
  /// device's actual language is read here.
  test('only the first language in the list decides', () {
    expect(
      resolve([const Locale('fr'), const Locale('es')]),
      AppLocales.english,
    );
    expect(
      resolve([const Locale('de'), const Locale('es'), const Locale('en')]),
      AppLocales.english,
    );
  });

  test('a device that names no language at all gets English', () {
    expect(resolve(null), AppLocales.english);
    expect(resolve(const <Locale>[]), AppLocales.english);
  });
}
