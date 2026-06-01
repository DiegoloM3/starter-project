import 'package:equatable/equatable.dart';

class CategoryProgressEntity extends Equatable {
  final String id;
  final String userId;
  final String categoryId;
  final double progress; // 0.0 to 1.0
  final int tipsCount;
  final DateTime updatedAt;

  const CategoryProgressEntity({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.progress,
    required this.tipsCount,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, categoryId, progress, tipsCount, updatedAt];
}
