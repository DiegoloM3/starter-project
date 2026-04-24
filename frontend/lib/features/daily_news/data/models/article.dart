import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

part 'article.g.dart';

/// Floor + NewsAPI data model.
///
/// Kept as a plain class (not freezed) because both `floor_generator` and
/// `retrofit_generator` expect a named-argument constructor and public
/// fields to synthesise their adapters. Mapping to/from the domain entity
/// happens explicitly via `toEntity`/`fromEntity` instead of inheritance.
@Entity(tableName: 'article', primaryKeys: ['id'])
@JsonSerializable()
class ArticleModel {
  const ArticleModel({
    this.id,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) =>
      _$ArticleModelFromJson(json);

  factory ArticleModel.fromEntity(ArticleEntity entity) => ArticleModel(
        id: entity.id,
        author: entity.author,
        title: entity.title,
        description: entity.description,
        url: entity.url,
        urlToImage: entity.urlToImage,
        publishedAt: entity.publishedAt,
        content: entity.content,
      );

  final int? id;

  @JsonKey(defaultValue: '')
  final String? author;

  @JsonKey(defaultValue: '')
  final String? title;

  @JsonKey(defaultValue: '')
  final String? description;

  @JsonKey(defaultValue: '')
  final String? url;

  @JsonKey(defaultValue: '')
  final String? urlToImage;

  @JsonKey(defaultValue: '')
  final String? publishedAt;

  @JsonKey(defaultValue: '')
  final String? content;

  Map<String, dynamic> toJson() => _$ArticleModelToJson(this);

  ArticleEntity toEntity() => ArticleEntity(
        id: id,
        author: author,
        title: title,
        description: description,
        url: url,
        urlToImage: (urlToImage == null || urlToImage!.isEmpty)
            ? kDefaultImage
            : urlToImage,
        publishedAt: publishedAt,
        content: content,
      );
}
