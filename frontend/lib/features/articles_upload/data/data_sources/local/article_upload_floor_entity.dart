import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';

@Entity(tableName: 'article_upload', primaryKeys: ['id'])
class ArticleUploadFloorEntity {
  final String id;
  final String title;
  final String description;
  final String content;
  final String author;
  final String authorUid;
  final String thumbnailURL;
  final String? sourceName;
  final int publishedAt;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  const ArticleUploadFloorEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    required this.authorUid,
    required this.thumbnailURL,
    this.sourceName,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  ArticleUploadEntity toEntity() {
    return ArticleUploadEntity(
      id: id,
      title: title,
      description: description,
      content: content,
      author: author,
      authorUid: authorUid,
      thumbnailURL: thumbnailURL,
      sourceName: sourceName,
      publishedAt: DateTime.fromMillisecondsSinceEpoch(publishedAt),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      deletedAt: deletedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(deletedAt!)
          : null,
    );
  }

  static ArticleUploadFloorEntity fromEntity(ArticleUploadEntity e) {
    return ArticleUploadFloorEntity(
      id: e.id ?? '',
      title: e.title,
      description: e.description,
      content: e.content,
      author: e.author,
      authorUid: e.authorUid,
      thumbnailURL: e.thumbnailURL,
      sourceName: e.sourceName,
      publishedAt: e.publishedAt.millisecondsSinceEpoch,
      createdAt: e.createdAt.millisecondsSinceEpoch,
      updatedAt: e.updatedAt.millisecondsSinceEpoch,
      deletedAt: e.deletedAt?.millisecondsSinceEpoch,
    );
  }
}
