import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// Row of the `saved_article` table: an article bookmarked on this device by
/// one account. Several accounts on the same phone keep separate bookmarks,
/// which is why the key is (owner, article).
///
/// Floor maps every inherited field to a column; `publishedAt`, `source` and
/// `category` go through the type converters registered on the database.
@Entity(tableName: 'saved_article', primaryKeys: ['ownerId', 'id'])
class SavedArticleModel extends ArticleEntity {
  final String ownerId;

  const SavedArticleModel({
    required this.ownerId,
    required super.id,
    required super.source,
    required super.title,
    required super.content,
    required super.author,
    required super.publishedAt,
    required super.category,
    super.description,
    super.authorId,
    super.imageUrl,
    super.imagePath,
    super.url,
  });

  factory SavedArticleModel.fromEntity(ArticleEntity entity, {required String ownerId}) {
    return SavedArticleModel(
      ownerId: ownerId,
      id: entity.id,
      source: entity.source,
      title: entity.title,
      content: entity.content,
      description: entity.description,
      author: entity.author,
      category: entity.category,
      authorId: entity.authorId,
      imageUrl: entity.imageUrl,
      imagePath: entity.imagePath,
      url: entity.url,
      publishedAt: entity.publishedAt,
    );
  }

  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      source: source,
      title: title,
      content: content,
      description: description,
      author: author,
      category: category,
      authorId: authorId,
      imageUrl: imageUrl,
      imagePath: imagePath,
      url: url,
      publishedAt: publishedAt,
    );
  }
}
