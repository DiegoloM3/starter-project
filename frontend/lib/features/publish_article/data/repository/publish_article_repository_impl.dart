import '../../domain/entities/publishable_article.dart';
import '../../domain/params/publish_article_params.dart';
import '../../domain/repository/publish_article_repository.dart';
import '../../domain/entities/publication_confirmation_pending.dart';
import '../data_sources/article_firestore_data_source.dart';
import '../data_sources/article_storage_data_source.dart';
import '../data_sources/publication_data_source_exception.dart';
import '../models/publishable_article_model.dart';

class PublishArticleRepositoryImpl implements PublishArticleRepository {
  final ArticleFirestoreDataSource _firestore;
  final ArticleStorageDataSource _storage;
  final Duration confirmationWait;
  // Only unresolved attempts are retained, for the lifetime of this repository.
  final _pending = <_PublicationAttempt>[];

  PublishArticleRepositoryImpl(this._firestore, this._storage,
      {this.confirmationWait = const Duration(seconds: 30)});

  @override
  Future<PublishableArticle> publishArticle(PublishArticleParams params) async {
    // A different form (including a reopened route) must explicitly reconcile
    // an uncertain publication before it can allocate another article ID.
    for (final attempt in _pending) {
      if (attempt.needsConfirmation && !attempt.matches(params)) {
        throw PublicationConfirmationPending(attempt.id);
      }
    }
    final attempt = _pending.firstWhere(
      (attempt) => attempt.matches(params),
      orElse: () {
        const names = {
          'image/jpeg': 'thumbnail.jpg',
          'image/png': 'thumbnail.png',
          'image/webp': 'thumbnail.webp',
        };
        final name = names[params.thumbnail.mimeType];
        if (name == null) {
          throw ArgumentError(
              'Publication parameters must be validated first.');
        }
        final id = _firestore.createArticleId();
        final attempt =
            _PublicationAttempt(params, id, 'media/articles/$id/$name');
        _pending.add(attempt);
        return attempt;
      },
    );
    return _runAttempt(attempt);
  }

  @override
  Future<PublishableArticle> confirmPublication(String articleId) {
    final attempt = _pending.firstWhere((attempt) => attempt.id == articleId);
    return _runAttempt(attempt);
  }

  Future<PublishableArticle> _runAttempt(_PublicationAttempt attempt) async {
    // Multiple callers share the same foreground operation, not another write.
    if (attempt.inFlight != null) return attempt.inFlight!;
    final operation = _publish(attempt);
    attempt.inFlight = operation;
    try {
      final entity = await operation;
      _pending.remove(attempt);
      return entity;
    } finally {
      attempt.inFlight = null;
    }
  }

  Future<PublishableArticle> _publish(_PublicationAttempt attempt) async {
    if (attempt.writeAttempted) {
      PublishableArticleModel? existing;
      try {
        existing = await _findArticle(attempt);
      } on PublicationDataSourceException {
        if (attempt.needsConfirmation) throw _confirmationPending(attempt);
        rethrow;
      }
      if (existing != null) return existing.toEntity();
      if (attempt.writeAcknowledged) {
        if (attempt.needsConfirmation) throw _confirmationPending(attempt);
        // Never repeat an acknowledged write just because confirmation failed.
        throw const PublicationDataSourceException(
          source: PublicationDataSource.firestore,
          operation: PublicationDataSourceOperation.getArticle,
          code: 'not-found',
          message: 'The acknowledged publication could not be confirmed.',
        );
      }
    }

    await _ensureThumbnail(attempt);
    attempt.writeAttempted = true;
    try {
      // Keep the native future after a foreground timeout: timeout does NOT
      // cancel a queued Firestore write. Only a settled failure can release it.
      attempt.writeFuture ??= _firestore.createArticle(
        articleId: attempt.id,
        params: attempt.params,
        thumbnailUrl: attempt.thumbnailUrl!,
      );
      await attempt.writeFuture!.timeout(confirmationWait,
          onTimeout: () => throw _confirmationPending(attempt));
      attempt.writeAcknowledged = true;
    } on PublicationConfirmationPending {
      rethrow;
    } catch (error) {
      attempt.writeFuture = null;
      // A rejected/uncertain write may refer to an earlier successful request.
      try {
        final existing = await _findArticle(attempt);
        if (existing != null) return existing.toEntity();
      } on PublicationConfirmationPending {
        // A stalled follow-up read must not hide a definite write rejection.
        if (!_isDefinitiveWriteFailure(error)) rethrow;
      } catch (_) {
        // Keep the original write error and retain the attempt for a later retry.
      }
      if (attempt.needsConfirmation && !_isDefinitiveWriteFailure(error)) {
        throw _confirmationPending(attempt);
      }
      attempt.needsConfirmation = false;
      rethrow;
    }

    try {
      return (await _readConfirmed(attempt)).toEntity();
    } on PublicationConfirmationPending {
      rethrow;
    } catch (_) {
      // One bounded reconciliation read, never another upload or write.
      try {
        return (await _readConfirmed(attempt)).toEntity();
      } catch (_) {
        if (attempt.needsConfirmation) throw _confirmationPending(attempt);
        rethrow;
      }
    }
  }

  PublicationConfirmationPending _confirmationPending(
      _PublicationAttempt attempt) {
    attempt.needsConfirmation = true;
    return PublicationConfirmationPending(attempt.id);
  }

  bool _isDefinitiveWriteFailure(Object error) =>
      error is PublicationDataSourceException &&
      error.operation == PublicationDataSourceOperation.createArticle &&
      const {'permission-denied', 'unauthenticated', 'invalid-argument'}
          .contains(error.code);

  Future<void> _ensureThumbnail(_PublicationAttempt attempt) async {
    if (attempt.thumbnailUrl != null) return;
    if (attempt.uploadAttempted) {
      attempt.thumbnailUrl =
          await _storage.findThumbnailDownloadUrl(attempt.path);
      if (attempt.thumbnailUrl != null) return;
    }
    attempt.uploadAttempted = true;
    try {
      attempt.thumbnailUrl = await _storage.uploadThumbnail(
          storagePath: attempt.path, thumbnail: attempt.params.thumbnail);
    } on PublicationDataSourceException catch (error) {
      const definitiveUploadErrors = {
        'unauthorized',
        'unauthenticated',
        'bucket-not-found',
        'project-not-found',
        'quota-exceeded',
        'invalid-argument',
      };
      if (error.operation == PublicationDataSourceOperation.uploadThumbnail &&
          definitiveUploadErrors.contains(error.code)) {
        rethrow;
      }
      // Includes failures obtaining the URL after a successful upload.
      attempt.thumbnailUrl =
          await _storage.findThumbnailDownloadUrl(attempt.path);
      if (attempt.thumbnailUrl == null) rethrow;
    }
  }

  Future<PublishableArticleModel?> _findArticle(
      _PublicationAttempt attempt) async {
    try {
      return await _readConfirmed(attempt);
    } on PublicationDataSourceException catch (error) {
      if (error.source == PublicationDataSource.firestore &&
          error.operation == PublicationDataSourceOperation.getArticle &&
          error.code == 'not-found') {
        return null;
      }
      rethrow;
    }
  }

  Future<PublishableArticleModel> _readConfirmed(
      _PublicationAttempt attempt) async {
    final model = await _firestore.getArticleById(attempt.id).timeout(
          confirmationWait,
          onTimeout: () => throw _confirmationPending(attempt),
        );
    final params = attempt.params;
    if (model.id != attempt.id ||
        model.author != params.author ||
        model.title != params.title ||
        model.description != params.description ||
        model.content != params.content ||
        model.thumbnailUrl != attempt.thumbnailUrl) {
      throw const PublicationDataSourceException(
        source: PublicationDataSource.firestore,
        operation: PublicationDataSourceOperation.getArticle,
        code: 'publication-conflict',
        message: 'The stored document does not match this publication attempt.',
      );
    }
    return model;
  }
}

class _PublicationAttempt {
  final PublishArticleParams params;
  final String id;
  final String path;
  String? thumbnailUrl;
  bool uploadAttempted = false;
  bool writeAttempted = false;
  bool writeAcknowledged = false;
  bool needsConfirmation = false;
  Future<void>? writeFuture;
  Future<PublishableArticle>? inFlight;

  _PublicationAttempt(this.params, this.id, this.path);

  bool matches(PublishArticleParams other) {
    if (params.author != other.author ||
        params.title != other.title ||
        params.description != other.description ||
        params.content != other.content ||
        params.thumbnail.fileName != other.thumbnail.fileName ||
        params.thumbnail.mimeType != other.thumbnail.mimeType ||
        params.thumbnail.bytes.length != other.thumbnail.bytes.length) {
      return false;
    }
    for (var i = 0; i < params.thumbnail.bytes.length; i++) {
      if (params.thumbnail.bytes[i] != other.thumbnail.bytes[i]) return false;
    }
    return true;
  }
}
