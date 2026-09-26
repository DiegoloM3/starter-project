import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'web_share.dart';

export 'web_share.dart' show WebShareStatus;

Future<WebShareStatus> performWebShare({
  required String title,
  required String text,
  required String link,
}) async {
  final data = web.ShareData(title: title, text: text, url: link);

  try {
    if (!web.window.navigator.canShare(data)) {
      return WebShareStatus.unsupported;
    }
  } catch (_) {
    // The browser does not expose the Web Share API or the current context is
    // not secure enough to use it. Let the UI provide a clipboard fallback.
    return WebShareStatus.unsupported;
  }

  try {
    await web.window.navigator.share(data).toDart;
    return WebShareStatus.shared;
  } on web.DOMException catch (error) {
    // Dismissing a native share sheet is a completed user decision, not an
    // error and should never copy a link unexpectedly.
    if (error.name == 'AbortError') {
      return WebShareStatus.dismissed;
    }
    rethrow;
  }
}
