import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String? bio;
  final String role;
  final List<String> preferredCategories;
  final bool onboardingCompleted;
  final bool? notificationsEnabled;
  final bool? darkMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.bio,
    required this.role,
    required this.preferredCategories,
    required this.onboardingCompleted,
    this.notificationsEnabled,
    this.darkMode,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoURL,
        bio,
        role,
        preferredCategories,
        onboardingCompleted,
        notificationsEnabled,
        darkMode,
        createdAt,
        updatedAt,
      ];
}
