import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/widgets/tags_field.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('TagsField', () {
    testWidgets('renders existing tags as Chips', (tester) async {
      await tester.pumpWidget(_wrap(TagsField(
        tags: const ['dart', 'flutter'],
        onChanged: (_) {},
      )));

      expect(find.text('dart'), findsOneWidget);
      expect(find.text('flutter'), findsOneWidget);
    });

    testWidgets('submitting text adds a new tag via onChanged', (tester) async {
      List<String>? received;
      await tester.pumpWidget(_wrap(TagsField(
        tags: const [],
        onChanged: (t) => received = t,
      )));

      await tester.enterText(find.byType(TextField), 'news');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(received, isNotNull);
      expect(received, contains('news'));
    });

    testWidgets('tapping remove icon removes the tag via onChanged', (tester) async {
      List<String> received = [];
      await tester.pumpWidget(_wrap(TagsField(
        tags: const ['dart'],
        onChanged: (t) => received = t,
      )));

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(received, isEmpty);
    });

    testWidgets('does not add tag when maxTags is reached', (tester) async {
      final existingTags = List.generate(10, (i) => 'tag$i');
      await tester.pumpWidget(_wrap(TagsField(
        tags: existingTags,
        onChanged: (_) {},
        maxTags: 10,
      )));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('typing comma commits the tag immediately', (tester) async {
      List<String>? received;
      await tester.pumpWidget(_wrap(TagsField(
        tags: const [],
        onChanged: (t) => received = t,
      )));

      await tester.enterText(find.byType(TextField), 'fitness,');
      await tester.pump();

      expect(received, contains('fitness'));
    });

    testWidgets('losing focus commits pending tag text', (tester) async {
      List<String>? received;
      await tester.pumpWidget(_wrap(Column(
        children: [
          TagsField(tags: const [], onChanged: (t) => received = t),
          const TextField(key: Key('other')),
        ],
      )));

      await tester.enterText(find.byType(TextField).first, 'pending');
      await tester.tap(find.byKey(const Key('other')));
      await tester.pumpAndSettle();

      expect(received, contains('pending'));
    });
  });
}
