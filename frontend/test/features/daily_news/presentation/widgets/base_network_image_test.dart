import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/base_network_image.dart';

void main() {
  group('BaseNetworkImage', () {
    const imageUrl = 'https://example.com/image.jpg';
    const width = 100.0;
    const height = 150.0;

    testWidgets(
        'renders CachedNetworkImage with correct properties and tests builders directly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BaseNetworkImage(
            imageUrl: imageUrl,
            width: width,
            height: height,
          ),
        ),
      );

      final cachedImageFinder = find.byType(CachedNetworkImage);
      expect(cachedImageFinder, findsOneWidget);

      final cachedImage = tester.widget<CachedNetworkImage>(cachedImageFinder);
      expect(cachedImage.imageUrl, imageUrl);

      final BuildContext context = tester.element(cachedImageFinder);

      final progressWidget = cachedImage.progressIndicatorBuilder!(
        context,
        imageUrl,
        const DownloadProgress(imageUrl, 10, 100),
      );

      await tester.pumpWidget(MaterialApp(home: progressWidget));
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(Container), findsWidgets);

      final loadingContainer =
          tester.widget<Container>(find.byType(Container).first);
      expect(loadingContainer.constraints?.minWidth, width);
      expect(loadingContainer.constraints?.minHeight, height);

      const List<int> transparentImage = <int>[
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
        0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
        0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
      ];
      final imageProvider = MemoryImage(Uint8List.fromList(transparentImage));
      final successWidget = cachedImage.imageBuilder!(context, imageProvider);

      await tester.pumpWidget(MaterialApp(home: successWidget));

      final successContainerFinder = find.byType(Container);
      expect(successContainerFinder, findsWidgets);

      final successContainer =
          tester.widget<Container>(successContainerFinder.first);
      expect(successContainer.decoration, isA<BoxDecoration>());
      final decoration = successContainer.decoration as BoxDecoration;
      expect(decoration.image?.image, imageProvider);

      final errorWidget = cachedImage.errorWidget!(
        context,
        imageUrl,
        Exception('Network Failure'),
      );

      await tester.pumpWidget(MaterialApp(home: errorWidget));
      expect(find.byIcon(Icons.error), findsOneWidget);

      final errorContainer =
          tester.widget<Container>(find.byType(Container).first);
      expect(errorContainer.constraints?.minWidth, width);
      expect(errorContainer.constraints?.minHeight, height);
    });
  });
}
