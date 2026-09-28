
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';

class UserArticleModel extends UserArticleEntity {
  const UserArticleModel({
    super.id,
    required super.title,
    required super.content,
    required super.thumbnailUrl,
    required super.publishedAt,
  });

  factory UserArticleModel.fromJson(Map<String, dynamic> map) {
    return UserArticleModel(
        id: map['id'] as String?,
        title: map['title'] ?? '',
      content: map['content'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      publishedAt: (map['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),

    );
   }

  factory UserArticleModel.fromRawData(Map<String, dynamic> map) {
    return UserArticleModel.fromJson(map);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'thumbnailUrl': thumbnailUrl,
      'publishedAt': publishedAt,
    };
  }

  UserArticleEntity toEntity() {
    return UserArticleEntity(
      id: id,
      title: title,
      content: content,
      thumbnailUrl: thumbnailUrl,
      publishedAt: publishedAt,
    );
  }
}