import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/config/theme/app_toasts.dart';
import 'package:toastification/toastification.dart';

void main() {
  Future<void> showScreenWithButton(WidgetTester tester, AppToast toast) async {
    await tester.pumpWidget(ToastificationConfigProvider(
      config: appToastificationConfig,
      child: MaterialApp(
        theme: lightTheme(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAppToast(context, toast),
              child: const Text('Act'),
            ),
          ),
        ),
      ),
    ));
  }

  testWidgets('shows the title and the description of the toast', (tester) async {
    await showScreenWithButton(tester, const AppToast.success('Article saved', description: 'Find it in Saved.'));

    await tester.tap(find.text('Act'));
    await tester.pumpAndSettle();

    expect(find.text('Article saved'), findsOneWidget);
    expect(find.text('Find it in Saved.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('closes by itself after a few seconds', (tester) async {
    await showScreenWithButton(tester, const AppToast.info('Removed from saved'));

    await tester.tap(find.text('Act'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Removed from saved'), findsNothing);
  });

  testWidgets('closes when the journalist taps its close button', (tester) async {
    await showScreenWithButton(tester, const AppToast.error('Your comment could not be sent'));

    await tester.tap(find.text('Act'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Your comment could not be sent'), findsNothing);
  });

  testWidgets('each type has its own icon and colors', (tester) async {
    Future<Icon> iconOf(AppToast toast) async {
      await tester.pumpWidget(MaterialApp(
        theme: lightTheme(),
        home: Scaffold(body: AppToastCard(toast: toast, onClose: () {})),
      ));
      return tester.widget<Icon>(find.descendant(of: find.byType(AppToastCard), matching: find.byType(Icon)).first);
    }

    expect((await iconOf(const AppToast.success('Done'))).color, AppPalette.light.success);
    expect((await iconOf(const AppToast.info('Removed'))).color, AppPalette.light.primary);
    expect((await iconOf(const AppToast.error('Failed'))).color, AppPalette.light.error);
  });
}
