import 'package:equatable/equatable.dart';

/// Sealed class hierarchy representing all possible failures in the app.
///
/// Use exhaustive pattern matching to handle each failure type:
/// ```dart
/// switch (failure) {
///   ServerFailure(:final message) => showError(message),
///   CacheFailure(:final message) => showCacheError(message),
///   AuthFailure(:final message) => showAuthError(message),
///   NetworkFailure() => showOfflineMessage(),
/// }
/// ```
sealed class Failure extends Equatable {
  const Failure({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure originating from a remote server (API or Firestore).
final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Failure originating from the local cache/database.
final class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Failure related to authentication operations.
final class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

/// Failure due to lack of network connectivity.
final class NetworkFailure extends Failure {
  const NetworkFailure()
    : super(message: 'No internet connection. Please check your network.');
}
