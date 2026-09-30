import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/length_counter.dart';

import '../../../../helpers/localized_app.dart';

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Future<void> showCounter(WidgetTester tester, {Locale locale = const Locale('en')}) {
    return tester.pumpWidget(localizedApp(
      locale: locale,
      home: Scaffold(body: LengthCounter(controller: controller, maxLength: 10)),
    ));
  }

  Text counter(WidgetTester tester) => tester.widget<Text>(find.byType(Text));

  testWidgets('follows the text as it is typed', (tester) async {
    await showCounter(tester);
    expect(find.text('0/10'), findsOneWidget);

    controller.text = 'Hello';
    await tester.pump();

    expect(find.text('5/10'), findsOneWidget);
  });

  testWidgets('counts an emoji as 2, like the security rules', (tester) async {
    await showCounter(tester);

    controller.text = 'Hi 👋';
    await tester.pump();

    expect(find.text('5/10'), findsOneWidget);
  });

  testWidgets('turns bold and red past the limit', (tester) async {
    await showCounter(tester);

    controller.text = 'Far too long';
    await tester.pump();

    final context = tester.element(find.byType(LengthCounter));
    expect(counter(tester).style!.color, Theme.of(context).colorScheme.error);
    expect(counter(tester).style!.fontWeight, FontWeight.bold);
  });

  testWidgets('tells screen readers how many characters are used, in their language', (tester) async {
    controller.text = 'Hola';
    await showCounter(tester, locale: const Locale('es'));

    expect(counter(tester).semanticsLabel, '4 de 10 caracteres usados');
  });
}
