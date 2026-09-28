import 'package:equatable/equatable.dart';

/// Authenticated user as known by Firebase Auth (uid, email, profile bits).
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, isAnonymous];
}
