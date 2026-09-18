import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/publishable_article_model.dart';
import 'publication_data_source_exception.dart';
import 'published_articles_firestore_data_source.dart';

class PublishedArticleDocument {
  final String id;
  final Map<String, dynamic> data;

  const PublishedArticleDocument({required this.id, required this.data});
}

abstract class PublishedArticlesFirestoreClient {
  Future<List<PublishedArticleDocument>> getArticlesByPublishedAtDescending();
}

class _FirebasePublishedArticlesFirestoreClient
    implements PublishedArticlesFirestoreClient {
  final FirebaseFirestore _firestore;

  _FirebasePublishedArticlesFirestoreClient(this._firestore);

  @override
  Future<List<PublishedArticleDocument>>
      getArticlesByPublishedAtDescending() async {
    final snapshot = await _firestore
        .collection('articles')
        .orderBy('publishedAt', descending: true)
        .get(const GetOptions(source: Source.server));

    return snapshot.docs
        .map((document) => PublishedArticleDocument(
              id: document.id,
              data: document.data(),
            ))
        .toList(growable: false);
  }
}

class FirebasePublishedArticlesFirestoreDataSource
    implements PublishedArticlesFirestoreDataSource {
  final PublishedArticlesFirestoreClient _client;

  FirebasePublishedArticlesFirestoreDataSource(FirebaseFirestore firestore)
      : _client = _FirebasePublishedArticlesFirestoreClient(firestore);

  FirebasePublishedArticlesFirestoreDataSource.withClient(this._client);

  @override
  Future<List<PublishableArticleModel>> getPublishedArticles() async {
    try {
      final documents = await _client.getArticlesByPublishedAtDescending();
      return documents.map(_toModel).toList(growable: false);
    } on FirebaseException catch (error) {
      throw PublicationDataSourceException(
        source: PublicationDataSource.firestore,
        operation: PublicationDataSourceOperation.listArticles,
        code: error.code,
        message: error.message ?? 'Unable to load published articles.',
        cause: error,
      );
    } on FormatException catch (error) {
      throw PublicationDataSourceException(
        source: PublicationDataSource.firestore,
        operation: PublicationDataSourceOperation.listArticles,
        code: 'invalid-data',
        message: 'A published article contains invalid data.',
        cause: error,
      );
    }
  }

  PublishableArticleModel _toModel(PublishedArticleDocument document) {
    final data = Map<String, dynamic>.from(document.data);
    for (final field in ['publishedAt', 'createdAt', 'updatedAt']) {
      final value = data[field];
      if (value is! Timestamp) {
        throw FormatException('Article field "$field" must be a Timestamp.');
      }
      data[field] = value.toDate();
    }
    return PublishableArticleModel.fromRawData(id: document.id, data: data);
  }
}
