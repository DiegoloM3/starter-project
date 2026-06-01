import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tortutip/features/tortu_feed/domain/entities/category_progress_entity.dart';

class CategoryProgressModel extends CategoryProgressEntity {
  const CategoryProgressModel({
    required super.id,
    required super.userId,
    required super.categoryId,
    required super.progress,
    required super.tipsCount,
    required super.updatedAt,
  });

  factory CategoryProgressModel.fromRawData(Map<String, dynamic> map) {
    return CategoryProgressModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      categoryId: map['category_id'] as String,
      progress: (map['progress'] as num).toDouble(),
      tipsCount: map['tips_count'] as int,
      updatedAt: (map['updated_at'] as Timestamp).toDate(),
    );
  }
}
