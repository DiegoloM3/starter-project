// Floor marks type converters as experimental although they have been stable since 1.0.
// ignore_for_file: experimental_member_use

import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// Stores [ArticleSource] by its enum name.
class ArticleSourceConverter extends TypeConverter<ArticleSource, String> {
  @override
  ArticleSource decode(String databaseValue) {
    return ArticleSource.values.firstWhere(
      (source) => source.name == databaseValue,
      orElse: () => ArticleSource.remote,
    );
  }

  @override
  String encode(ArticleSource value) => value.name;
}
