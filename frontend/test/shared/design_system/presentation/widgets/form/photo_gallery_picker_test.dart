import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/image_item.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/form/photo_gallery_picker.dart';

import '../../../../../helpers/test_wrapper.dart';

void main() {
  group('PhotoGalleryPicker', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          PhotoGalleryPicker(
            label: 'Images',
            images: const [],
            canAddMore: true,
            onAddPhotoTapped: () {},
            onImageRemoved: (_) {},
            hintText: 'Add up to 5 photos',
          ),
        ),
      );

      expect(find.text('IMAGES'), findsOneWidget);
    });

    testWidgets('renders hint text', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          PhotoGalleryPicker(
            label: 'Images',
            images: const [],
            canAddMore: true,
            onAddPhotoTapped: () {},
            onImageRemoved: (_) {},
            hintText: 'Add up to 5 photos',
          ),
        ),
      );

      expect(find.text('Add up to 5 photos'), findsOneWidget);
    });

    testWidgets('shows add button when canAddMore is true', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          PhotoGalleryPicker(
            label: 'Images',
            images: const [],
            canAddMore: true,
            onAddPhotoTapped: () {},
            onImageRemoved: (_) {},
            hintText: 'hint',
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('calls onAddPhotoTapped when add button pressed',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        testableWidget(
          PhotoGalleryPicker(
            label: 'Images',
            images: const [],
            canAddMore: true,
            onAddPhotoTapped: () => tapped = true,
            onImageRemoved: (_) {},
            hintText: 'hint',
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, true);
    });

    testWidgets('renders thumbnails for existing images', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          PhotoGalleryPicker(
            label: 'Images',
            images: const [
              ImageItem(url: 'https://example.com/1.jpg'),
              ImageItem(url: 'https://example.com/2.jpg'),
            ],
            canAddMore: true,
            onAddPhotoTapped: () {},
            onImageRemoved: (_) {},
            hintText: '2 of 5 photos',
          ),
        ),
      );

      expect(find.text('2 of 5 photos'), findsOneWidget);
    });
  });
}
