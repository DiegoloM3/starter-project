import 'dart:async';

import 'helpers/pump_app.dart';

/// Runs before every test file: the fallback values mocktail needs for
/// `any()` are registered once here instead of in each file.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  registerCommonFallbacks();
  await testMain();
}
