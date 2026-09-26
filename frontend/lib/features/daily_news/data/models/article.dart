import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import '../../../../core/constants/constants.dart';

String articleBookmarkKey(ArticleEntity article) {
  final rawUrl = article.url?.trim() ?? '';
  if (rawUrl.isNotEmpty) {
    return 'url:${_canonicalArticleUrl(rawUrl)}';
  }

  final fallback = [
    article.author,
    article.title,
    article.description,
    article.publishedAt,
    article.content,
    article.urlToImage,
  ].map((value) => value?.trim() ?? '').join('\u001F');
  return 'fields:${sha256.convert(utf8.encode(fallback))}';
}

String _canonicalArticleUrl(String value) {
  final parsed = Uri.tryParse(value);
  if (parsed == null || parsed.host.isEmpty) return value;

  final queryEntries = parsed.queryParameters.entries.toList()
    ..sort((a, b) {
      final keyOrder = a.key.compareTo(b.key);
      return keyOrder == 0 ? a.value.compareTo(b.value) : keyOrder;
    });

  return parsed
      .replace(
        scheme: parsed.scheme.toLowerCase(),
        host: parsed.host.toLowerCase(),
        path: parsed.path.isEmpty ? '/' : parsed.path,
        queryParameters:
            queryEntries.isEmpty ? null : Map.fromEntries(queryEntries),
        fragment: '',
      )
      .toString();
}

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

  factory ArticleModel.fromJson(Map<String, dynamic> map) {
    return ArticleModel(
      author: map['author'] ?? "",
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      url: map['url'] ?? "",
      urlToImage: map['urlToImage'] != null && map['urlToImage'] != ""
          ? map['urlToImage']
          : kDefaultImage,
      publishedAt: map['publishedAt'] ?? "",
      content: map['content'] ?? "",
    );
  }

  factory ArticleModel.fromRawData(Map<String, dynamic> map) => ArticleModel(
        id: map['id'] as int?,
        author: map['author'] as String?,
        title: map['title'] as String?,
        description: map['description'] as String?,
        url: map['url'] as String?,
        urlToImage: map['urlToImage'] as String?,
        publishedAt: map['publishedAt'] as String?,
        content: map['content'] as String?,
      );

  Map<String, dynamic> toRawData() => {
        'id': id,
        'bookmarkKey': articleBookmarkKey(this),
        'author': author,
        'title': title,
        'description': description,
        'url': url,
        'urlToImage': urlToImage,
        'publishedAt': publishedAt,
        'content': content,
      };

  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
        id: entity.id,
        author: entity.author,
        title: entity.title,
        description: entity.description,
        url: entity.url,
        urlToImage: entity.urlToImage,
        publishedAt: entity.publishedAt,
        content: entity.content);
  }

  ArticleEntity toEntity() => ArticleEntity(
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
