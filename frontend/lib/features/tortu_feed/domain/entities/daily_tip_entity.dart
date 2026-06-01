import 'package:equatable/equatable.dart';

class DailyTipEntity extends Equatable {
  final String id;
  final String userId;
  final String articleId;
  final String categoryId;
  final String date; // "yyyy-MM-dd"
  final DateTime createdAt;

  const DailyTipEntity({
    required this.id,
    required this.userId,
    required this.articleId,
    required this.categoryId,
    required this.date,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, articleId, categoryId, date, createdAt];
}
