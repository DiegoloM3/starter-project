import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';

void main() {
  test('the light theme keeps the white background of the design', () {
    final light = theme();

    expect(light.brightness, Brightness.light);
    expect(light.scaffoldBackgroundColor, Colors.white);
    expect(light.appBarTheme.backgroundColor, Colors.white);
  });

  test('the dark theme has a dark background and light app bar content', () {
    final dark = darkTheme();

    expect(dark.brightness, Brightness.dark);
    expect(dark.scaffoldBackgroundColor.computeLuminance(), lessThan(0.1));
    expect(dark.appBarTheme.iconTheme!.color!.computeLuminance(), greaterThan(0.7));
    expect(dark.appBarTheme.titleTextStyle!.color!.computeLuminance(), greaterThan(0.7));
  });

  test('both themes use the app font', () {
    expect(darkTheme().textTheme.bodyLarge!.fontFamily, 'Muli');
    expect(theme().textTheme.bodyLarge!.fontFamily, 'Muli');
  });
}
