import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/publish/photo_field.dart';

import '../../../../../helpers/pump_app.dart';

/// A 1×1 transparent PNG, enough for the preview to decode.
const _onePixelPng =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

void main() {
  late File photo;

  setUp(() {
    final dir = Directory.systemTemp.createTempSync('photo_field');
    addTearDown(() => dir.deleteSync(recursive: true));
    photo = File('${dir.path}/photo.png')..writeAsBytesSync(base64Decode(_onePixelPng));
  });

  testWidgets('without a photo the plate invites to add one', (tester) async {
    var picked = false;
    await pumpApp(
      tester,
      PhotoField(localPath: null, remoteUrl: null, isUploading: false, onPick: () => picked = true, onRemove: () {}),
    );

    await tester.tap(find.text('Add a photo'));
    expect(picked, isTrue);
  });

  testWidgets('a picked photo shows its preview and can be removed', (tester) async {
    var removed = false;
    await pumpApp(
      tester,
      PhotoField(localPath: photo.path, remoteUrl: null, isUploading: false, onPick: () {}, onRemove: () => removed = true),
    );
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Add a photo'), findsNothing);
    await tester.tap(find.text('REMOVE'));
    expect(removed, isTrue);
  });

  testWidgets('while uploading a scrim covers the preview', (tester) async {
    await pumpApp(
      tester,
      PhotoField(localPath: photo.path, remoteUrl: null, isUploading: true, onPick: () {}, onRemove: () {}),
    );
    await tester.pump();

    expect(find.text('UPLOADING PHOTO…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
