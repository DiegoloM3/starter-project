// Floor marks type converters as experimental although they have been stable since 1.0.
// ignore_for_file: experimental_member_use

import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// Stores [NewsCategory] by its provider value (e.g. `technology`).
class NewsCategoryConverter extends TypeConverter<NewsCategory, String> {
  @override
  NewsCategory decode(String databaseValue) => NewsCategory.fromApiValue(databaseValue);

  @override
  String encode(NewsCategory value) => value.apiValue;
}
