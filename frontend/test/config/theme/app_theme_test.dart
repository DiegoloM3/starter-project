import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_motion.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_theme.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

void main() {
  test('the light theme carries the light palette and brand colours', () {
    final theme = AppTheme.light();

    expect(theme.brightness, Brightness.light);
    expect(theme.extension<AppPalette>(), AppPalette.light);
    expect(theme.colorScheme.primary, AppPalette.light.primary);
    expect(theme.scaffoldBackgroundColor, AppPalette.light.background);
    expect(theme.useMaterial3, isTrue);
  });

  test('the dark theme swaps in the dark palette', () {
    final theme = AppTheme.dark();

    expect(theme.brightness, Brightness.dark);
    expect(theme.extension<AppPalette>(), AppPalette.dark);
    expect(theme.colorScheme.surface, AppPalette.dark.background);
  });

  test('every style uses DM Sans', () {
    final text = AppTheme.light().textTheme;

    expect(text.headlineLarge?.fontFamily, AppTypography.family);
    expect(text.bodyLarge?.fontFamily, AppTypography.family);
    expect(text.bodyLarge?.fontSize, 16);
  });

  testWidgets('context.palette reads the extension and motion respects reduce-motion', (tester) async {
    late AppPalette palette;
    late Duration duration;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              palette = context.palette;
              duration = AppMotion.durationFor(context, AppMotion.medium);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(palette, AppPalette.light);
    expect(duration, Duration.zero);
  });
}
