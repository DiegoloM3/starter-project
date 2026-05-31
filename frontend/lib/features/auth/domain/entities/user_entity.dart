import 'package:equatable/equatable.dart';

/// Domain entity representing a user in the system.
class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, createdAt];
}

/// Sealed class representing the authentication status of the user.
///
/// Enables exhaustive pattern matching:
/// ```dart
/// switch (status) {
///   Authenticated(:final user) => showHome(user),
///   Unauthenticated() => showLogin(),
///   AuthUnknown() => showSplash(),
/// }
/// ```
sealed class AuthStatus {
  const AuthStatus();
}

/// User is authenticated and [user] is available.
final class Authenticated extends AuthStatus {
  const Authenticated({required this.user});
  final UserEntity user;
}

/// User is not authenticated.
final class Unauthenticated extends AuthStatus {
  const Unauthenticated();
}

/// Authentication state is still being determined (e.g., on app launch).
final class AuthUnknown extends AuthStatus {
  const AuthUnknown();
}
