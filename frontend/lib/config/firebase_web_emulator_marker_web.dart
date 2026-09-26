import 'package:web/web.dart' as web;

void clearAuthEmulatorMarker() {
  // firebase_auth_web uses this key for its debug hot-reload shortcut. A
  // release build must connect to the emulator on every fresh page load.
  web.window.sessionStorage.removeItem('[DEFAULT]-firebaseEmulatorOrigin');
}
