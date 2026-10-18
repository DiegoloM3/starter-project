import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';

void main() {
  Future<void> pumpChips(WidgetTester tester, ThemeData theme) {
    return tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Row(
            children: [
              FilterChip(label: const Text('Selected'), selected: true, onSelected: (_) {}),
              FilterChip(label: const Text('Unselected'), selected: false, onSelected: (_) {}),
            ],
          ),
        ),
      ),
    );
  }

  Color? labelColorOf(WidgetTester tester, String label) {
    final text = tester.widget<RichText>(find.descendant(of: find.text(label), matching: find.byType(RichText)));
    return text.text.style?.color;
  }

  for (final (name, theme) in [('light', lightTheme()), ('dark', darkTheme())]) {
    testWidgets('selected chips use the background color for their label in the $name theme', (tester) async {
      await pumpChips(tester, theme);

      expect(labelColorOf(tester, 'Selected'), theme.colorScheme.onPrimary);
      expect(labelColorOf(tester, 'Unselected'), theme.colorScheme.onSurface);
    });
  }
}
