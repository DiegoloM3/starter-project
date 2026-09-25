import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

@Entity(tableName: 'article', primaryKeys: ['id'])
class ArticleModel extends ArticleEntity {
  // NewsAPI's free plan cuts `content` at ~200 characters and appends a
  // count of what it left out: "...the storm [+2345 chars]".
  static final _truncationMarker = RegExp(r'\s*\[\+\d+ chars\]\s*$');

  /// Whose saved list this row belongs to (a Firebase Auth uid) -- purely a
  /// local-storage scoping concern, not part of what an article IS, so it
  /// lives here and not on ArticleEntity. Nullable only because rows saved
  /// before this field existed have none; those simply stop appearing for
  /// anyone, which is the safe failure mode for "we don't actually know
  /// whose save this was" (see the version 4 to 5 migration).
  final String? savedBy;

  const ArticleModel({
    super.id,
    super.author,
    super.title,
    super.description,
    super.url,
    super.urlToImage,
    super.publishedAt,
    super.content,
    super.sourceName,
    this.savedBy,
  });

  // retrofit's generated NewsApiService calls fromJson by convention.
  factory ArticleModel.fromJson(Map<String, dynamic> map) =>
      ArticleModel.fromRawData(map);

  factory ArticleModel.fromRawData(Map<String, dynamic> map) {
    final source = map['source'];
    final sourceName = source is Map ? source['name'] as String? : null;
    return ArticleModel(
      author: map['author'] ?? '',
      title: _withoutSourceSuffix(map['title'] ?? '', sourceName),
      description: map['description'] ?? '',
      url: map['url'] ?? '',
      // Empty when there's no image; the UI shows its own placeholder.
      urlToImage: map['urlToImage'] ?? '',
      publishedAt: map['publishedAt'] ?? '',
      content: (map['content'] as String? ?? '')
          .replaceFirst(_truncationMarker, ''),
      sourceName: sourceName,
    );
  }

  factory ArticleModel.fromEntity(ArticleEntity entity, {String? savedBy}) {
    return ArticleModel(
      id: entity.id,
      author: entity.author,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      urlToImage: entity.urlToImage,
      publishedAt: entity.publishedAt,
      content: entity.content,
      sourceName: entity.sourceName,
      savedBy: savedBy,
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
      sourceName: sourceName,
    );
  }

  /// NewsAPI titles end in " - {source}", sometimes shortened ("BBC" for
  /// "BBC News"); the source is shown on its own. Anything else after the
  /// last " - " is part of the headline and stays.
  static String _withoutSourceSuffix(String title, String? sourceName) {
    final cut = title.lastIndexOf(' - ');
    if (sourceName == null || sourceName.isEmpty || cut < 0) return title;
    final tail = title.substring(cut + 3).trim();
    final namesSource = tail.isNotEmpty &&
        (sourceName.startsWith(tail) || tail.startsWith(sourceName));
    return namesSource ? title.substring(0, cut) : title;
  }
}
