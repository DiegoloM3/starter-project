import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/article_body_editing_controller.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/article_content_field.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

void main() {
  Future<void> pumpField(WidgetTester tester, String text) async {
    final controller = ArticleBodyEditingController(text: text);
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: SingleChildScrollView(
          child: ArticleContentField(
            controller: controller,
            isPreviewing: false,
            onPreviewingChanged: (_) {},
          ),
        ),
      ),
    ));
  }

  TextSpan limitSpan(WidgetTester tester, String label) {
    final counter = tester.widget<Text>(find.textContaining(label));
    return (counter.textSpan! as TextSpan)
        .children!
        .whereType<TextSpan>()
        .last;
  }

  testWidgets('counts words and characters against the limit', (tester) async {
    await pumpField(tester, 'Hello **big** world');

    expect(find.text('3 words  ·  19/5000'), findsOneWidget);
  });

  testWidgets('the character count only turns red close to the limit',
      (tester) async {
    await pumpField(tester, 'Hello world');
    expect(limitSpan(tester, '11/5000').style, isNull);

    await pumpField(tester, 'x' * 4800);
    final errorColor =
        Theme.of(tester.element(find.byType(ArticleContentField)))
            .colorScheme
            .error;
    expect(limitSpan(tester, '4800/5000').style?.color, errorColor);
  });
}
