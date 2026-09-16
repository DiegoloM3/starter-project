import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// Article as returned by the news provider's JSON API.
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.content,
    required super.author,
    required super.publishedAt,
    super.description,
    super.imageUrl,
    super.url,
  }) : super(source: ArticleSource.remote);

  static const String _unknownAuthor = 'Unknown author';

  /// Builds a model from one entry of the provider's `articles` array.
  ///
  /// The provider omits or nulls many fields. Missing text falls back to an
  /// empty string, a missing author to a neutral label, and a missing or
  /// unparsable date to the Unix epoch so the article sorts last.
  factory ArticleModel.fromRawData(Map<String, dynamic> raw) {
    final url = _string(raw['url']);
    final title = _string(raw['title']);
    final content = _string(raw['content']);
    final description = _string(raw['description']);
    final imageUrl = _string(raw['urlToImage']);
    final author = _string(raw['author']);

    return ArticleModel(
      id: url.isNotEmpty ? url : title,
      title: title,
      content: content.isNotEmpty ? content : description,
      description: description.isNotEmpty ? description : null,
      author: author.isNotEmpty ? author : _unknownAuthor,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
      url: url.isNotEmpty ? url : null,
      publishedAt: _date(raw['publishedAt']),
    );
  }

  /// The provider does not tag articles with a category, so the caller
  /// supplies the one it queried for.
  ArticleEntity toEntity({NewsCategory category = NewsCategory.general}) {
    return ArticleEntity(
      id: id,
      source: source,
      title: title,
      content: content,
      description: description,
      author: author,
      category: category,
      imageUrl: imageUrl,
      url: url,
      publishedAt: publishedAt,
    );
  }

  static String _string(Object? value) => value is String ? value.trim() : '';

  static DateTime _date(Object? value) {
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed.toUtc();
    }
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}
