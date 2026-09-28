import 'package:equatable/equatable.dart';

/// Public profile of an author, stored at `users/{uid}`.
///
/// Deliberately excludes the email: these documents are publicly readable so
/// article cards can resolve any author's avatar. The email stays in
/// Firebase Auth.
class UserProfileEntity extends Equatable {
  final String id;
  final String? displayName;
  final String? photoUrl;

  const UserProfileEntity({
    required this.id,
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, displayName, photoUrl];
}
