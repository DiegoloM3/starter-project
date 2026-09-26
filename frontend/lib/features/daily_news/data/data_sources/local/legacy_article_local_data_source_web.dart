import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/article.dart';
import 'article_local_data_source.dart';

class LegacyArticleLocalDataSource implements ArticleLocalDataSource {
  final SharedPreferences _preferences;
  const LegacyArticleLocalDataSource(this._preferences);

  static const _key = 'saved-news-articles';

  @override
  Future<List<ArticleModel>> getArticles() async {
    final values = _preferences.getStringList(_key) ?? const [];
    return values
        .map((value) =>
            ArticleModel.fromRawData(jsonDecode(value) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveArticle(ArticleModel article) async {
    final articles = await getArticles();
    final withoutDuplicate = articles
        .where(
            (item) => articleBookmarkKey(item) != articleBookmarkKey(article))
        .toList();
    withoutDuplicate.add(article);
    await _preferences.setStringList(
      _key,
      withoutDuplicate.map((item) => jsonEncode(item.toRawData())).toList(),
    );
  }

  @override
  Future<void> removeArticle(ArticleModel article) async {
    final articles = await getArticles();
    await _preferences.setStringList(
      _key,
      articles
          .where(
              (item) => articleBookmarkKey(item) != articleBookmarkKey(article))
          .map((item) => jsonEncode(item.toRawData()))
          .toList(),
    );
  }
}

Future<LegacyArticleLocalDataSource>
    createLegacyArticleLocalDataSource() async {
  return LegacyArticleLocalDataSource(await SharedPreferences.getInstance());
}
