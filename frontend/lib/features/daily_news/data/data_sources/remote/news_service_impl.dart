import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_service.dart.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/page.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewsServiceImpl implements NewsService {
  final _collection = FirebaseFirestore.instance.collection('articles');
  final _storage = FirebaseStorage.instance.ref('media/articles/');

  @override
  Future<void> saveArticle(ArticleModel article) async =>
      await _collection.add(article.toJson());

  @override
  Future<PageModel<ArticleModel>> getNewsArticles({
    required int page,
    int size = 10,
    int? total,
  }) async {
    final (startIndex, endIndex) = PageEntity.getIndexes(
      page: page,
      size: size,
      total: total,
    );

    final results = await Future.wait([
      _collection.count().get(),
      _collection.orderBy('publishedAt', descending: true).get(),
    ]);
    final totalQuery = results[0] as AggregateQuerySnapshot;
    final snapshot = results[1] as QuerySnapshot<Map<String, dynamic>>;
    final totalCount = totalQuery.count ?? snapshot.size;

    final articles = snapshot.docs
        .skip(startIndex)
        .take(endIndex - startIndex + 1)
        .map((doc) => ArticleModel.fromJson(map: doc.data(), id: doc.id))
        .toList();

    return PageModel(
      content: articles,
      page: page,
      totalPages: (totalCount / size).ceil(),
      total: totalCount,
    );
  }

  @override
  Future<String> uploadImage(File file) async {
    final fileName = file.path.split('/').last;
    final ref = _storage.child(fileName);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
