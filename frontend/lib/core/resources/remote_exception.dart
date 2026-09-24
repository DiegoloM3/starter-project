/// An operation against an external service failed.
///
/// Data sources throw this instead of the provider's own exception type
/// (`FirebaseAuthException`, `FirebaseException`, `DioException`,
/// `PlatformException`). That is what lets `ARCHITECTURE_VIOLATIONS.md` 1.2.4
/// hold literally: the provider SDK stays inside `data/data_sources`, and a
/// repository still recognises a failure — by its [code] — without importing
/// Firebase, Dio or the platform channels.
///
/// [code] is the provider's own code, kept verbatim (`not-found`,
/// `weak-password`, `permission-denied`). Repositories map it onto the
/// domain's failures; nothing above the data layer ever sees it.
class RemoteException implements Exception {
  /// The provider's error code, or [unknownCode] when it did not give one.
  final String code;

  /// The provider's own message, for logs. Never shown to a reader: wording
  /// is the presentation layer's job.
  final String? message;

  /// The original error, kept so a stack trace is not lost on the way up.
  final Object? cause;

  const RemoteException(this.code, {this.message, this.cause});

  /// Stands in for a provider error that arrived with no code of its own.
  static const String unknownCode = 'unknown';

  /// The backend could not be reached. It is Firestore's own code for it, and
  /// the one the data sources raise when a call runs past its deadline: a
  /// provider that never answers and one that answers "offline" are the same
  /// failure to everything above this class.
  static const String unavailableCode = 'unavailable';

  @override
  String toString() => 'RemoteException($code)';
}
