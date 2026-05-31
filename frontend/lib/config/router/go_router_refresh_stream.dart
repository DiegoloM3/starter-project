import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';

/// Adapter that bridges a Stream to a Listenable for GoRouter's refreshListenable.
///
/// This class solves the integration between flutter_bloc's Stream-based state management
/// and go_router's Listenable-based refresh mechanism. It uses ChangeNotifier solely as
/// a technical bridge, NOT for state management.
///
/// **Memory Management:**
/// - Properly cancels stream subscription in dispose()
/// - Must be disposed when no longer needed to prevent memory leaks
///
/// **Usage:**
/// ```dart
/// final authBloc = serviceLocator<AuthBloc>();
/// final refreshStream = GoRouterRefreshStream(authBloc.stream);
///
/// final router = GoRouter(
///   refreshListenable: refreshStream,
///   // ...
/// );
///
/// // Later, in dispose:
/// refreshStream.dispose();
/// ```
class GoRouterRefreshStream<T> extends ChangeNotifier {
  /// Creates a listenable that notifies listeners when the stream emits.
  ///
  /// The [stream] should typically be a BLoC's state stream that emits
  /// whenever authentication or authorization state changes.
  GoRouterRefreshStream(Stream<T> stream) {
    _subscription = stream.listen((_) {
      if (!_disposed) {
        log(
          'GoRouterRefreshStream: Stream emitted a new value, notifying listeners.',
        );
        notifyListeners();
      }
    });
  }

  late final StreamSubscription<T> _subscription;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _subscription.cancel();
    super.dispose();
  }
}
