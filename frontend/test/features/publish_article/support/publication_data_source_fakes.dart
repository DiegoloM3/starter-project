import 'dart:async';

import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/article_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/article_storage_data_source.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/publication_data_source_exception.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/models/publishable_article_model.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/params/publish_article_params.dart';

PublicationDataSourceException dataError(PublicationDataSource source,
        PublicationDataSourceOperation operation, String code) =>
    PublicationDataSourceException(
        source: source,
        operation: operation,
        code: code,
        message: 'Controlled failure');

PublishArticleParams publicationInput(
        {String title = 'Title',
        String mime = 'image/jpeg',
        String name = '../../unsafe.name',
        List<int> bytes = const [1, 2, 3]}) =>
    PublishArticleParams(
        author: 'Author',
        title: title,
        description: 'Description',
        content: 'Content',
        thumbnail:
            ArticleThumbnail(fileName: name, mimeType: mime, bytes: bytes));

class PublicationFirestoreFake implements ArticleFirestoreDataSource {
  final List<String> events;
  final documents = <String, PublishableArticleModel>{};
  final reads = <Object>[];
  Object? idError;
  Object? createError;
  Completer<void>? createGate;
  Completer<void>? readGate;
  bool storeBeforeError = false;
  int ids = 0;
  PublishArticleParams? receivedParams;

  PublicationFirestoreFake(this.events);

  @override
  String createArticleId() {
    events.add('id');
    if (idError != null) throw idError!;
    return 'article-${++ids}';
  }

  @override
  Future<void> createArticle(
      {required String articleId,
      required PublishArticleParams params,
      required String thumbnailUrl}) async {
    events.add('create:$articleId');
    receivedParams = params;
    if (createGate != null) await createGate!.future;
    if (createError == null || storeBeforeError) {
      documents[articleId] = PublishableArticleModel(
          id: articleId,
          author: params.author,
          title: params.title,
          description: params.description,
          content: params.content,
          thumbnailUrl: thumbnailUrl,
          publishedAt: DateTime.utc(2020),
          createdAt: DateTime.utc(2021),
          updatedAt: DateTime.utc(2022));
    }
    if (createError != null) throw createError!;
  }

  @override
  Future<PublishableArticleModel> getArticleById(String articleId) async {
    events.add('get:$articleId');
    if (readGate != null) await readGate!.future;
    if (reads.isNotEmpty) {
      final result = reads.removeAt(0);
      if (result is PublishableArticleModel) return result;
      throw result;
    }
    final model = documents[articleId];
    if (model != null) return model;
    throw dataError(PublicationDataSource.firestore,
        PublicationDataSourceOperation.getArticle, 'not-found');
  }
}

class PublicationStorageFake implements ArticleStorageDataSource {
  final List<String> events;
  final objects = <String, String>{};
  Object? uploadError;
  Object? lookupError;
  bool storeBeforeError = false;
  Completer<void>? gate;
  ArticleThumbnail? receivedThumbnail;

  PublicationStorageFake(this.events);

  @override
  Future<String> uploadThumbnail(
      {required String storagePath,
      required ArticleThumbnail thumbnail}) async {
    events.add('upload:$storagePath');
    receivedThumbnail = thumbnail;
    if (gate != null) await gate!.future;
    final url =
        'https://firebasestorage.googleapis.com/${Uri.encodeComponent(storagePath)}';
    if (uploadError == null || storeBeforeError) objects[storagePath] = url;
    if (uploadError != null) throw uploadError!;
    return url;
  }

  @override
  Future<String?> findThumbnailDownloadUrl(String storagePath) async {
    events.add('find:$storagePath');
    if (lookupError != null) throw lookupError!;
    return objects[storagePath];
  }
}
