import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import '../../../../core/constants/constants.dart';

/// Data layer view of [ArticleEntity]: one headline, as the News API sends it
/// and as the saved-articles table stores it.
///
/// The `@Entity` annotation is Floor's, and is the one provider import that
/// could not be moved into `data/data_sources` (rule 1.2.4). Floor generates
/// its DAO from the annotated class the DAO names, so splitting the table row
/// off into its own class needs `build_runner`, which cannot run in this
/// project — `floor_generator` and `retrofit_generator` pin incompatible
/// analyzer versions (decision #19). Recorded as a known deviation rather
/// than worked around.
@Entity(tableName: 'article', primaryKeys: ['id'])
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    super.id,
    super.author,
    super.title,
    super.description,
    super.url,
    super.urlToImage,
    super.publishedAt,
    super.content,
  });

  /// The News API is generous with nulls: a headline routinely arrives with no
  /// author, no description and no image. The entity is nullable throughout,
  /// but empty strings are what the screens are written against, so this is
  /// where the nulls stop.
  factory ArticleModel.fromRawData(Map<String, dynamic> data) {
    final imageUrl = data['urlToImage'] as String?;

    return ArticleModel(
      author: data['author'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      url: data['url'] as String? ?? '',
      // A card with no picture would leave a hole in the feed, so an article
      // without one is given the placeholder instead of nothing.
      urlToImage:
          imageUrl == null || imageUrl.isEmpty ? kDefaultImage : imageUrl,
      publishedAt: data['publishedAt'] as String? ?? '',
      content: contentWithoutTruncationMarker(data['content'] as String?),
    );
  }

  /// Strips the News API's own truncation marker off the body.
  ///
  /// The free tier sends about 200 characters of each article and signs off
  /// with `[+2431 chars]`. That is a note from the API to whoever is
  /// integrating it, not part of the story, and it was being printed at the
  /// end of every article as though the journalist had typed it. The text
  /// still ends mid-sentence — that is the tier, not a bug we can fix here —
  /// so the reader screen says where the rest is instead.
  static String contentWithoutTruncationMarker(String? content) {
    if (content == null || content.isEmpty) {
      return '';
    }

    return content.replaceAll(_truncationMarker, '').trimRight();
  }

  /// `[+1234 chars]`, and only that.
  ///
  /// The ellipsis the API leaves in front of it is kept: it honestly says the
  /// text stops mid-sentence, and it cannot be told apart from one the
  /// journalist wrote. Only the bracketed count is unambiguously the API's,
  /// and only at the very end — square brackets are ordinary punctuation in a
  /// news story, so a marker in the middle of one is left alone.
  static final RegExp _truncationMarker = RegExp(
    r'\s*\[\+\d+\s*chars\]\s*$',
  );

  /// Retrofit builds models straight from the decoded JSON body, and names the
  /// factory it calls `fromJson`. It is kept as the alias it is.
  factory ArticleModel.fromJson(Map<String, dynamic> json) =>
      ArticleModel.fromRawData(json);

  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
      id: entity.id,
      author: entity.author,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      urlToImage: entity.urlToImage,
      publishedAt: entity.publishedAt,
      content: entity.content,
    );
  }

  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      author: author,
      title: title,
      description: description,
      url: url,
      urlToImage: urlToImage,
      publishedAt: publishedAt,
      content: content,
    );
  }
}
