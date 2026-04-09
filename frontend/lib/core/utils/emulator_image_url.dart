import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

/// Rewrites Firebase Storage emulator download URLs so the host is reachable
/// from the current platform.
///
/// The Storage emulator embeds the host the *uploading* client used into the
/// returned download URL. That host is platform-specific:
///   - iOS simulator / web / desktop upload with `localhost` / `127.0.0.1`
///   - Android emulator uploads with `10.0.2.2`
///
/// When another platform later tries to load that URL, the host is wrong:
///   - Android cannot reach `localhost` (it points at the device itself)
///   - iOS/desktop cannot reach `10.0.2.2`
///
/// This helper rewrites the host of any emulator URL into whatever the
/// current platform can actually reach. No-op in release builds and on web.
String rewriteEmulatorImageUrl(String url) {
  if (!kDebugMode || kIsWeb) return url;
  if (Platform.isAndroid) {
    return url
        .replaceFirst('://localhost', '://10.0.2.2')
        .replaceFirst('://127.0.0.1', '://10.0.2.2');
  }
  // iOS simulator, macOS, Linux, Windows: swap Android-only hosts back to
  // localhost so URLs uploaded from Android can still be fetched.
  return url.replaceFirst('://10.0.2.2', '://localhost');
}
