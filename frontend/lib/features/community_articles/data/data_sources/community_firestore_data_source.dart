import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../config/firebase_options.dart';
import '../../domain/entities/article_image.dart';
import '../../domain/entities/community_article.dart';
import '../../domain/params/publish_article_params.dart';
import '../models/community_article_model.dart';

class CommunityFirestoreDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  CommunityFirestoreDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ??
            FirebaseFirestore.instanceFor(
              app: Firebase.app(),
              databaseId: firebaseFirestoreDatabaseId,
            ),
        storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _articles =>
      firestore.collection('articles');

  Future<List<CommunityArticleEntity>> getPublishedArticles() async {
    final snapshot = await _articles
        .where('publishedAt', isLessThanOrEqualTo: Timestamp.now())
        .orderBy('publishedAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .map((doc) => CommunityArticleModel.fromRawData({
              ...doc.data(),
              'id': doc.id,
            }))
        .toList();
  }

  Future<CommunityArticleEntity?> getPublishedArticleById(
      String articleId) async {
    final document = await _articles.doc(articleId).get();
    if (!document.exists || document.data() == null) return null;
    return CommunityArticleModel.fromRawData({
      ...document.data()!,
      'id': document.id,
    });
  }

  Future<CommunityArticleEntity> publishArticle(
    PublishArticleParams params,
  ) async {
    final user = auth.currentUser;
    if (user == null) throw StateError('Sign in to publish an article.');
    final image = params.image;
    if (image == null || !image.isSupportedRaster) {
      throw const FormatException('Attach a valid JPEG, PNG, or WebP image.');
    }

    // A client request ID makes retries idempotent after an ambiguous network result.
    final document = _articles.doc(params.clientId);
    final payloadHash = _payloadHash(params.title, params.content, image);
    final existing = await document.get();
    if (existing.exists) {
      final existingData = existing.data()!;
      if (existingData['ownerUid'] != user.uid) {
        throw StateError('This article identifier is already in use.');
      }
      if (existingData['payloadHash'] != payloadHash) {
        throw StateError(
            'The retry payload does not match the committed article.');
      }
      return CommunityArticleModel.fromRawData({
        ...existingData,
        'id': document.id,
      });
    }

    final safeName = _safeFileName(image.fileName);
    final thumbnailPath = 'media/articles/${user.uid}/${document.id}/$safeName';
    final reference = storage.ref(thumbnailPath);
    String thumbnailUrl;
    try {
      final metadata = await reference.getMetadata();
      final storedHash = metadata.customMetadata?['payloadHash'];
      if (storedHash != payloadHash || metadata.contentType != image.mimeType) {
        throw StateError('An existing thumbnail does not match this article.');
      }
      thumbnailUrl = await reference.getDownloadURL();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found' &&
          error.code != 'storage/object-not-found') {
        rethrow;
      }
      await reference.putData(
        Uint8List.fromList(image.bytes),
        SettableMetadata(
          contentType: image.mimeType,
          customMetadata: {'payloadHash': payloadHash},
        ),
      );
      thumbnailUrl = await reference.getDownloadURL();
    }

    // The Firestore write is the acknowledgement boundary. Keep a local
    // timestamp only for the response fallback below; persisted timestamps
    // remain authoritative server timestamps.
    final submittedAt = DateTime.now().toUtc();
    final now = FieldValue.serverTimestamp();
    final data = <String, dynamic>{
      'author': user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : 'Case Study Symmetry journalist',
      'title': params.title,
      'description': descriptionFor(params.content),
      'url': '',
      'urlToImage': thumbnailUrl,
      'publishedAt': now,
      'content': params.content,
      'thumbnailPath': thumbnailPath,
      'payloadHash': payloadHash,
      'ownerUid': user.uid,
      'createdAt': now,
      'updatedAt': now,
    };

    // Never delete a thumbnail on an unknown write failure: Firestore may have committed
    // even when its response was lost. Retrying reuses the same object and request ID.
    await document.set(data);
    try {
      final saved = await document.get();
      return CommunityArticleModel.fromRawData({
        ...saved.data()!,
        'id': saved.id,
      });
    } catch (_) {
      // The write has already been acknowledged. A transient cache or rules
      // evaluation failure during readback must not report a successful
      // publish as failed. Retries use the request ID and read the committed
      // server document, while this response uses the local submission time.
      return CommunityArticleModel(
        id: document.id,
        author: data['author'] as String,
        title: params.title,
        description: data['description'] as String,
        url: '',
        urlToImage: thumbnailUrl,
        publishedAt: submittedAt.toIso8601String(),
        content: params.content,
        thumbnailPath: thumbnailPath,
        payloadHash: payloadHash,
        ownerUid: user.uid,
        createdAt: submittedAt,
        updatedAt: submittedAt,
      );
    }
  }

  String _payloadHash(String title, String content, ArticleImageEntity image) {
    final bytes = <int>[
      ...utf8.encode(title),
      0,
      ...utf8.encode(content),
      0,
      ...image.bytes,
    ];
    return sha256.convert(bytes).toString();
  }

  /// Returns a preview that never exceeds the documented 240 UTF-16 code-unit bound.
  ///
  /// Truncation walks Unicode scalar values so it cannot split a surrogate pair.
  static String descriptionFor(String content) {
    if (content.length <= 240) return content;
    final preview = <int>[];
    var codeUnits = 0;
    for (final rune in content.runes) {
      final width = rune > 0xFFFF ? 2 : 1;
      if (codeUnits + width > 239) break;
      preview.add(rune);
      codeUnits += width;
    }
    return '${String.fromCharCodes(preview)}…';
  }

  String _safeFileName(String value) {
    final base =
        value.split('/').last.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (base.isEmpty) return 'article-image.png';
    return base.substring(0, base.length > 120 ? 120 : base.length);
  }
}
