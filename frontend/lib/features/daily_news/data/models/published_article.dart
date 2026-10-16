import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/published_article.dart';

class PublishedArticleModel extends PublishedArticleEntity {
  static const String titleField = 'title';
  static const String contentField = 'content';
  static const String thumbnailPathField = 'thumbnailURL';
  static const String publishedAtField = 'publishedAt';

  PublishedArticleModel({
    required String title,
    required String content,
    required String thumbnailUrl,
    required DateTime publishedAt,
  }) : super(title: title, content: content, thumbnailUrl: thumbnailUrl, publishedAt: publishedAt);

  /// [rawData] is a document of the `articles` collection; [thumbnailUrl] is
  /// the download URL of the image referenced by its `thumbnailURL` path.
  factory PublishedArticleModel.fromRawData(Map<String, dynamic> rawData, {required String thumbnailUrl}) {
    return PublishedArticleModel(
      title: rawData[titleField] as String,
      content: rawData[contentField] as String,
      thumbnailUrl: thumbnailUrl,
      publishedAt: rawData[publishedAtField] as DateTime,
    );
  }

  /// Builds the document stored for a new article. The publication date is
  /// set by the server when the document is created.
  static Map<String, Object> toRawData(ArticleDraftEntity draft, {required String thumbnailPath}) {
    return {
      titleField: draft.title,
      contentField: draft.content,
      thumbnailPathField: thumbnailPath,
    };
  }

  PublishedArticleEntity toEntity() {
    return PublishedArticleEntity(
      title: title!,
      content: content!,
      thumbnailUrl: urlToImage!,
      publishedAt: DateTime.parse(publishedAt!),
    );
  }
}
