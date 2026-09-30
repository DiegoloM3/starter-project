// End-to-end test of the "publish an article" user journey (CODING_GUIDELINES 4.2).
//
// It drives the real app on a device against the Firebase Emulator Suite: real Firestore,
// real Storage and the real security rules of backend/. Only the system gallery, which is
// not part of the app, is replaced by a picker that always returns one test image.
//
// Run it with the emulators started (see README.md):
//   cd backend && firebase emulators:start --only firestore,storage
//   cd frontend && flutter test integration_test --dart-define=USE_FIREBASE_EMULATORS=true
// Add --dart-define=SLOW_MOTION=true to pause after every step (to record a demo video).

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/pick_thumbnail_from_gallery.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/main.dart';

const bool _useFirebaseEmulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS');
const Duration _stepPause = bool.fromEnvironment('SLOW_MOTION') ? Duration(milliseconds: 1500) : Duration.zero;
const String _contentHint = 'Add article here… Use the toolbar for **bold** text and ## subtitles.';

// A 160x90 PNG, small enough to embed and still a valid image for Storage and the UI.
const String _testImagePng =
    'iVBORw0KGgoAAAANSUhEUgAAAKAAAABaCAIAAACwpMoFAAAA0UlEQVR42u3dsQ2AIBBAUTDOgXthwWpYOJibuIGhMEQv77V293NIRy61J+JajEBgBEZgBEZgBEZggYliff58nc2Mvm/bDxvsiEZgov2DBw965hu8HtlgRzQCIzACIzACI7DACIzACIzACIzAAiMwAiMwAiMwAiOwwAiMwAiMwAiMwAIjMAIjMAIjMAILjMAIjMAIjMAIjMACIzACIzACIzACC4zACIzACIzACCywEQiMwKT/Py/ruXcbjMAIzItyqd0UbDACIzACIzACI7DAhHAD1dkKzjMJT84AAAAASUVORK5CYII=';

class _GalleryWithOneImage implements PickThumbnailFromGalleryUseCase {
  final ArticleThumbnailEntity _image;

  _GalleryWithOneImage(this._image);

  @override
  Future<DataState<ArticleThumbnailEntity?>> call({void params}) async => DataSuccess(_image);
}

Future<ArticleThumbnailEntity> _writeTestImage() async {
  final bytes = base64Decode(_testImagePng);
  final file = await File('${Directory.systemTemp.path}/integration-test-image.png').writeAsBytes(bytes);
  return ArticleThumbnailEntity(localPath: file.path, sizeInBytes: bytes.length);
}

/// Pumps frames until [finder] finds something. Unlike pumpAndSettle, it does not wait
/// for spinners (image placeholders) to stop, and it fails with a clear message.
Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  final deadline = DateTime.now().add(const Duration(seconds: 45));
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(deadline)) fail('Timed out waiting for $finder');
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> _tapAndWait(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 600));
  await _pauseForDemo(tester);
}

Future<void> _pauseForDemo(WidgetTester tester) async {
  if (_stepPause == Duration.zero) return;
  final end = DateTime.now().add(_stepPause);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (!_useFirebaseEmulators) {
      fail('Refusing to run against the production backend. '
          'Start the Firebase emulators and pass --dart-define=USE_FIREBASE_EMULATORS=true');
    }
    await initializeDependencies();
    sl.allowReassignment = true;
    sl.registerSingleton<PickThumbnailFromGalleryUseCase>(_GalleryWithOneImage(await _writeTestImage()));
  });

  testWidgets('a journalist publishes an article and finds it in the Community tab', (tester) async {
    final title = 'Integration test ${DateTime.now().millisecondsSinceEpoch}';
    // The journey looks for the English texts, whatever the language of the device.
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(const MyApp());
    await _pumpUntilFound(tester, find.text('Community'));

    // Open the publish screen from the home screen.
    await _tapAndWait(tester, find.text('Community'));
    await _tapAndWait(tester, find.byTooltip('Publish an article'));
    await _pumpUntilFound(tester, find.text('Attach Image'));

    // Publishing an empty article explains what is missing.
    await _tapAndWait(tester, find.text('Publish Article').last);
    expect(find.text('Add a title for your article.'), findsOneWidget);
    expect(find.text('Attach an image to illustrate your article.'), findsOneWidget);

    // Write the article.
    await tester.enterText(find.widgetWithText(TextField, 'Title'), title);
    await _pauseForDemo(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Written by'), 'Integration Bot');
    await _pauseForDemo(tester);
    await _tapAndWait(tester, find.text('Attach Image'));
    expect(find.text('Change image'), findsOneWidget);
    final contentField = find.widgetWithText(TextField, _contentHint);
    await tester.scrollUntilVisible(contentField, 300, scrollable: find.byType(Scrollable).first);
    await tester.enterText(contentField, '## Subtitle\n\nThis is **breaking** news.');
    await _pauseForDemo(tester);

    // Publish it: back on the home screen, confirmed, and listed in Community.
    await _tapAndWait(tester, find.text('Publish Article').last);
    await _pumpUntilFound(tester, find.text('Your article has been published.'));
    await _pumpUntilFound(tester, find.text(title));
    await _pauseForDemo(tester);

    // The backend stored exactly what backend/docs/DB_SCHEMA.md describes.
    final stored = await FirebaseFirestore.instance
        .collection('articles')
        .where('title', isEqualTo: title)
        .limit(1)
        .get();
    final article = stored.docs.single;
    expect(article.data().keys, unorderedEquals(['title', 'content', 'description', 'author', 'thumbnailURL', 'publishedAt']));
    expect(article['author'], 'Integration Bot');
    expect(article['description'], 'Subtitle This is breaking news.');
    expect(article['publishedAt'], isA<Timestamp>());
    expect(article['thumbnailURL'], contains('media%2Farticles%2F${article.id}.png'));
    final thumbnail = await FirebaseStorage.instance.ref('media/articles/${article.id}.png').getMetadata();
    expect(thumbnail.contentType, 'image/png');

    // The detail screen renders the Markdown content.
    await _tapAndWait(tester, find.text(title));
    await _pumpUntilFound(tester, find.textContaining('Subtitle', findRichText: true));
    expect(find.textContaining('Integration Bot', findRichText: true), findsOneWidget);
    await _pauseForDemo(tester);
  });
}
