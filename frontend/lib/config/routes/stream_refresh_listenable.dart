import 'dart:async';

import 'package:flutter/foundation.dart';

/// Turns any stream into a [Listenable] so `GoRouter.refreshListenable` can
/// re-run its redirect whenever the stream emits.
class StreamRefreshListenable extends ChangeNotifier {
  late final StreamSubscription<Object?> _subscription;

  StreamRefreshListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
