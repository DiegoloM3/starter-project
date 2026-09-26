import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/resources/data_state.dart';
import '../../domain/entities/article_image.dart';
import '../../domain/entities/community_article.dart';
import '../../domain/params/publish_article_params.dart';
import '../../domain/usecases/pick_article_image.dart';
import '../../domain/usecases/publish_article.dart';

sealed class PublishArticleState {
  const PublishArticleState();
}

class PublishArticleIdle extends PublishArticleState {
  final ArticleImageEntity? image;
  const PublishArticleIdle({this.image});
}

class PublishArticlePickingImage extends PublishArticleState {
  final ArticleImageEntity? image;
  const PublishArticlePickingImage({this.image});
}

/// A photo has been selected, but it is not publishable until the user
/// confirms the fixed-ratio crop in the editor.
class PublishArticleCropRequired extends PublishArticleState {
  final ArticleImageEntity? image;
  final ArticleImageEntity sourceImage;
  final int sessionId;

  const PublishArticleCropRequired({
    required this.sourceImage,
    this.image,
    this.sessionId = 0,
  });
}

class PublishArticleSubmitting extends PublishArticleState {
  final ArticleImageEntity? image;
  const PublishArticleSubmitting({this.image});
}

class PublishArticleSuccess extends PublishArticleState {
  final CommunityArticleEntity article;
  const PublishArticleSuccess(this.article);
}

class PublishArticleFailure extends PublishArticleState {
  final String message;
  final ArticleImageEntity? image;
  const PublishArticleFailure(this.message, {this.image});
}

class PublishArticleCubit extends Cubit<PublishArticleState> {
  final PublishArticleUseCase _publish;
  final PickArticleImageUseCase _pickImage;
  bool _submitting = false;
  ArticleImageEntity? _image;
  ArticleImageEntity? _sourceImage;
  ArticleImageEntity? _pendingSourceImage;
  int _cropSession = 0;
  int? _pendingCropSession;
  bool _pickingImage = false;
  String? _requestId;
  String? _requestFingerprint;

  PublishArticleCubit(this._publish, this._pickImage)
      : super(const PublishArticleIdle());

  ArticleImageEntity? get image => _image;
  ArticleImageEntity? get cropSourceImage => _sourceImage ?? _image;
  bool get isSubmitting => _submitting;

  Future<void> selectImage() async {
    if (_submitting || isClosed || _pickingImage) return;
    _pickingImage = true;
    emit(PublishArticlePickingImage(image: _image));
    try {
      final result = await _pickImage();
      if (isClosed) return;
      if (result is DataSuccess<ArticleImageEntity?>) {
        if (result.data != null) {
          _beginCropSession(result.data!);
          return;
        }
        emit(PublishArticleIdle(image: _image));
      } else {
        emit(PublishArticleFailure(
          result.error?.message ?? 'Unable to select that image.',
          image: _image,
        ));
      }
    } finally {
      _pickingImage = false;
    }
  }

  /// Opens the crop editor again for the original, uncropped source image.
  void adjustImage() {
    if (_submitting || isClosed) return;
    final source = cropSourceImage;
    if (source == null) return;
    _beginCropSession(source);
  }

  /// Commits the crop output. Only this method makes a picked photo
  /// publishable, so canceling the crop editor cannot replace the current
  /// image accidentally.
  void confirmImageCrop(
    ArticleImageEntity croppedImage, {
    int? sessionId,
  }) {
    if (_submitting ||
        isClosed ||
        _pendingSourceImage == null ||
        (sessionId != null && sessionId != _pendingCropSession)) {
      return;
    }
    _sourceImage = _pendingSourceImage;
    _pendingSourceImage = null;
    _pendingCropSession = null;
    _image = croppedImage;
    emit(PublishArticleIdle(image: _image));
  }

  void cancelImageCrop({int? sessionId}) {
    if (isClosed || (sessionId != null && sessionId != _pendingCropSession)) {
      return;
    }
    _pendingSourceImage = null;
    _pendingCropSession = null;
    emit(PublishArticleIdle(image: _image));
  }

  void removeImage() {
    if (_submitting || isClosed) return;
    _image = null;
    _sourceImage = null;
    _pendingSourceImage = null;
    _pendingCropSession = null;
    emit(const PublishArticleIdle());
  }

  void _beginCropSession(ArticleImageEntity sourceImage) {
    final sessionId = ++_cropSession;
    _pendingSourceImage = sourceImage;
    _pendingCropSession = sessionId;
    emit(PublishArticleCropRequired(
      image: _image,
      sourceImage: sourceImage,
      sessionId: sessionId,
    ));
  }

  Future<void> submit({required String title, required String content}) async {
    if (_submitting || isClosed) return;
    final fingerprint =
        _payloadFingerprint(title.trim(), content.trim(), _image);
    if (_requestFingerprint != fingerprint) {
      _requestId = _clientRequestId();
      _requestFingerprint = fingerprint;
    }
    _submitting = true;
    emit(PublishArticleSubmitting(image: _image));
    late DataState<CommunityArticleEntity> result;
    try {
      result = await _publish(PublishArticleParams(
        clientId: _requestId!,
        title: title,
        content: content,
        image: _image,
      ));
    } catch (error) {
      result = DataFailed(AppFailure(
        'Article could not be published.',
        cause: error,
      ));
    }
    _submitting = false;
    if (isClosed) return;
    if (result is DataSuccess<CommunityArticleEntity> && result.data != null) {
      _requestId = null;
      _requestFingerprint = null;
      emit(PublishArticleSuccess(result.data!));
    } else {
      emit(PublishArticleFailure(
        result.error?.message ?? 'Article could not be published.',
        image: _image,
      ));
    }
  }

  String _clientRequestId() {
    final random =
        Random().nextInt(0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
    return 'article-${DateTime.now().microsecondsSinceEpoch}-$random';
  }

  String _payloadFingerprint(
    String title,
    String content,
    ArticleImageEntity? image,
  ) {
    final imagePart = image == null
        ? 'no-image'
        : '${image.fileName}|${image.mimeType}|${image.bytes.join(',')}';
    return '${title.length}:$title|${content.length}:$content|$imagePart';
  }
}
