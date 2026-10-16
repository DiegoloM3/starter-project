import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:integration_test/integration_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/publish_article/publish_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/add_article_button.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_thumbnail_preview.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/attach_image_button.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/main.dart';

/// The system photo picker cannot be driven by a test, so the native picker
/// is replaced by one that returns a prepared image. The app code (gallery
/// data source, repository, use case and cubit) runs unchanged.
class FakeImagePickerPlatform extends ImagePickerPlatform {
  final String imagePath;

  FakeImagePickerPlatform(this.imagePath);

  @override
  Future<XFile?> getImageFromSource({required ImageSource source, ImagePickerOptions options = const ImagePickerOptions()}) async {
    return XFile(imagePath);
  }
}

const List<int> _onePixelPng = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0xF0,
  0x1F, 0x00, 0x05, 0x00, 0x01, 0xFF, 0x89, 0x99, 0x3D, 0x1D, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45,
  0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

/// The journey runs against the Firebase Local Emulator Suite (started from
/// `backend/` with `firebase emulators:start --only firestore,storage`), so
/// the real security rules are exercised and no test data reaches the
/// production project. `10.0.2.2` is the host machine seen from the Android
/// emulator.
const String _emulatorHost = '10.0.2.2';

void connectToFirebaseEmulators() {
  FirebaseFirestore.instance.useFirestoreEmulator(_emulatorHost, 8080);
  FirebaseStorage.instance.useStorageEmulator(_emulatorHost, 9199);
}

Future<String> createTestImage() async {
  final image = File('${Directory.systemTemp.path}/publish_article_journey.png');
  await image.writeAsBytes(_onePixelPng);
  return image.path;
}

/// Waits for a widget to appear and for its entrance animation to finish.
/// `pumpAndSettle` cannot be used because the home feed keeps loading
/// indicators animating while the images download.
Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 100 && finder.evaluate().isEmpty; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsWidgets);
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a journalist publishes an article from the home screen', (tester) async {
    ImagePickerPlatform.instance = FakeImagePickerPlatform(await createTestImage());
    await initializeDependencies();
    connectToFirebaseEmulators();
    await tester.pumpWidget(const MyApp());

    await pumpUntilFound(tester, find.byType(AddArticleButton));
    await tester.tap(find.byType(AddArticleButton));
    await pumpUntilFound(tester, find.byType(PublishArticleView));

    final title = 'Integration test article ${DateTime.now().millisecondsSinceEpoch}';
    await tester.enterText(find.byType(TextField).first, title);
    await tester.enterText(find.byType(TextField).last, 'This is breaking news!');
    await tester.tap(find.byType(AttachImageButton));
    await pumpUntilFound(tester, find.byType(ArticleThumbnailPreview));

    await tester.tap(find.text('Publish Article'));
    await pumpUntilFound(tester, find.text('Article published successfully.'));

    expect(find.byType(PublishArticleView), findsNothing);
    expect(find.byType(DailyNews), findsOneWidget);
    await pumpUntilFound(tester, find.text(title));
    await sl.reset();
  });
}
