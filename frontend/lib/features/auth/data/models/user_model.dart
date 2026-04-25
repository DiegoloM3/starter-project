import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required String uid,
    required String email,
    required String displayName,
    String? photoURL,
    String? bio,
    required String role,
    required List<String> preferredCategories,
    required bool onboardingCompleted,
    bool? notificationsEnabled,
    bool? darkMode,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          uid: uid,
          email: email,
          displayName: displayName,
          photoURL: photoURL,
          bio: bio,
          role: role,
          preferredCategories: preferredCategories,
          onboardingCompleted: onboardingCompleted,
          notificationsEnabled: notificationsEnabled,
          darkMode: darkMode,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw Exception('User document not found: ${doc.id}');
    return UserModel(
      uid: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      photoURL: data['photoURL'] as String?,
      bio: data['bio'] as String?,
      role: data['role'] as String,
      preferredCategories: List<String>.from(data['preferredCategories'] ?? []),
      onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
      notificationsEnabled: data['notificationsEnabled'] as bool?,
      darkMode: data['darkMode'] as bool?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      if (photoURL != null) 'photoURL': photoURL,
      if (bio != null) 'bio': bio,
      'role': role,
      'preferredCategories': preferredCategories,
      'onboardingCompleted': onboardingCompleted,
      if (notificationsEnabled != null)
        'notificationsEnabled': notificationsEnabled,
      if (darkMode != null) 'darkMode': darkMode,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
