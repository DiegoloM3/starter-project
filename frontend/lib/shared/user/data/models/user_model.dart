import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.avatarUrl,
    required super.bio,
    required super.role,
    required super.gender,
    required super.ageRange,
    required super.createdAt,
    super.streakDays = 0,
    super.lastFeedDate = '',
    super.overallProgress = 0.0,
  });

  factory UserModel.fromRawData(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatar_url'] ?? '',
      bio: data['bio'] ?? '',
      role: data['role'] ?? 'reader',
      gender: data['gender'] ?? '',
      ageRange: data['age_range'] ?? '',
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      streakDays: (data['streak_days'] as int?) ?? 0,
      lastFeedDate: (data['last_feed_date'] as String?) ?? '',
      overallProgress: (data['overall_progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
