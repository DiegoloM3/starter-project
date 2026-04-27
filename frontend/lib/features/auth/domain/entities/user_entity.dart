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
  final int onboardingStep;
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
    this.onboardingStep = 0,
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
        onboardingStep,
        notificationsEnabled,
        darkMode,
        createdAt,
        updatedAt,
      ];

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? bio,
    String? role,
    List<String>? preferredCategories,
    bool? onboardingCompleted,
    int? onboardingStep,
    bool? notificationsEnabled,
    bool? darkMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
