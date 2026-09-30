import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/add_thumbnail.dart';

import '../../../../helpers/localized_app.dart';

Widget inApp(Widget child) => localizedApp(home: Scaffold(body: child));

void main() {
  group('without an image', () {
    testWidgets('shows the Attach Image button, which opens the gallery', (tester) async {
      var galleryOpenings = 0;
      await tester.pumpWidget(inApp(AddThumbnail(onPickImage: () => galleryOpenings++)));

      await tester.tap(find.text('Attach Image'));

      expect(galleryOpenings, 1);
      expect(find.text('Change image'), findsNothing);
    });

    testWidgets('is disabled without a callback', (tester) async {
      await tester.pumpWidget(inApp(const AddThumbnail()));

      final button = tester.widget<ButtonStyleButton>(find.byWidgetPredicate((widget) => widget is ButtonStyleButton));
      expect(button.onPressed, isNull);
    });
  });

  group('with an image', () {
    testWidgets('replaces the button with the image, which reopens the gallery when tapped', (tester) async {
      var galleryOpenings = 0;
      await tester.pumpWidget(inApp(AddThumbnail(imagePath: '/gallery/photo.jpg', onPickImage: () => galleryOpenings++)));

      await tester.tap(find.text('Change image'));

      expect(galleryOpenings, 1);
      expect(find.text('Attach Image'), findsNothing);
    });
  });

  testWidgets('shows the error message', (tester) async {
    await tester.pumpWidget(inApp(const AddThumbnail(errorText: 'Attach an image to illustrate your article.')));

    expect(find.text('Attach an image to illustrate your article.'), findsOneWidget);
  });
}
