import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String bio;
  final String role; // 'reader' | 'writer'
  final String gender;
  final String ageRange;
  final DateTime createdAt;
  final int streakDays;
  final String lastFeedDate;
  final double overallProgress;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.bio,
    required this.role,
    required this.gender,
    required this.ageRange,
    required this.createdAt,
    this.streakDays = 0,
    this.lastFeedDate = '',
    this.overallProgress = 0.0,
  });

  bool get isDoneToday {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return lastFeedDate == today;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        avatarUrl,
        bio,
        role,
        gender,
        ageRange,
        createdAt,
        streakDays,
        lastFeedDate,
        overallProgress,
      ];
}
