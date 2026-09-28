import 'package:json_annotation/json_annotation.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';

part 'article.g.dart';

/// Data-layer view of [ArticleEntity] with NewsAPI mapping.
@JsonSerializable()
class ArticleModel extends ArticleEntity {
  @override
  @JsonKey(name: 'author')
  final String? authorDisplayName;

  const ArticleModel({
    super.id,
    this.authorDisplayName,
    super.title,
    super.urlToImage,
    super.publishedAt,
    super.content,
    super.authorId,
  }) : super(authorDisplayName: authorDisplayName);

  /// Builds a model from a NewsAPI JSON map.
  factory ArticleModel.fromJson(Map<String, dynamic> json) =>
      _$ArticleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleModelToJson(this);

  /// Builds a model from a domain [entity].
  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
      id: entity.id,
      authorDisplayName: entity.authorDisplayName,
      title: entity.title,
      urlToImage: entity.urlToImage,
      publishedAt: entity.publishedAt,
      content: entity.content,
      authorId: entity.authorId,
    );
  }

  /// Builds a model from external raw data.
  factory ArticleModel.fromRawData(Map<String, dynamic> raw) =>
      ArticleModel.fromJson(raw);

  /// Converts this model to its domain [ArticleEntity].
  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      authorDisplayName: authorDisplayName,
      title: title,
      urlToImage: urlToImage,
      publishedAt: publishedAt,
      content: content,
      authorId: authorId,
    );
  }

  ArticleModel copyWith({
    String? id,
    String? authorDisplayName,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    String? publishedAt,
    String? content,
    String? authorId,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      title: title ?? this.title,
      urlToImage: urlToImage ?? this.urlToImage,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
    );
  }
}
