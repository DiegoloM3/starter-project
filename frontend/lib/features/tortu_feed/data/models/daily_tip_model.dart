import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tortutip/features/tortu_feed/domain/entities/daily_tip_entity.dart';

class DailyTipModel extends DailyTipEntity {
  const DailyTipModel({
    required super.id,
    required super.userId,
    required super.articleId,
    required super.categoryId,
    required super.date,
    required super.createdAt,
  });

  factory DailyTipModel.fromRawData(Map<String, dynamic> map) {
    return DailyTipModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      articleId: map['article_id'] as String,
      categoryId: map['category_id'] as String,
      date: map['date'] as String,
      createdAt: (map['created_at'] as Timestamp).toDate(),
    );
  }
}
