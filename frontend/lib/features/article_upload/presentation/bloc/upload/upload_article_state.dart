import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_location.dart';

final class UploadArticleState extends Equatable {
  final int? draftId;
  final String? editingArticleId;
  final String? existingThumbnailUrl;
  final String? localImagePath;
  final Uint8List? compressedBytes;
  final String title;
  final String description;
  final String content;
  final ArticleCategory? category;
  final List<String> tags;
  final String language;
  final ArticleLocation? location;
  final bool isPickingImage;
  final bool isPublishing;
  final bool isPublished;
  final DateTime? lastSavedAt;
  final AppException? error;

  const UploadArticleState({
    this.draftId,
    this.editingArticleId,
    this.existingThumbnailUrl,
    this.localImagePath,
    this.compressedBytes,
    this.title = '',
    this.description = '',
    this.content = '',
    this.category,
    this.tags = const [],
    this.language = 'en',
    this.location,
    this.isPickingImage = false,
    this.isPublishing = false,
    this.isPublished = false,
    this.lastSavedAt,
    this.error,
  });

  bool get canPublish =>
      title.length >= 5 &&
      title.length <= 200 &&
      description.length >= 20 &&
      description.length <= 500 &&
      content.length >= 50 &&
      // In edit mode the existing thumbnail is kept; new bytes only required for create.
      (editingArticleId != null || compressedBytes != null) &&
      category != null &&
      tags.isNotEmpty;

  UploadArticleState copyWith({
    Object? draftId = _sentinel,
    Object? editingArticleId = _sentinel,
    Object? existingThumbnailUrl = _sentinel,
    Object? localImagePath = _sentinel,
    Object? compressedBytes = _sentinel,
    String? title,
    String? description,
    String? content,
    Object? category = _sentinel,
    List<String>? tags,
    String? language,
    Object? location = _sentinel,
    bool? isPickingImage,
    bool? isPublishing,
    bool? isPublished,
    Object? lastSavedAt = _sentinel,
    Object? error = _sentinel,
  }) {
    return UploadArticleState(
      draftId: draftId == _sentinel ? this.draftId : draftId as int?,
      editingArticleId: editingArticleId == _sentinel
          ? this.editingArticleId
          : editingArticleId as String?,
      existingThumbnailUrl: existingThumbnailUrl == _sentinel
          ? this.existingThumbnailUrl
          : existingThumbnailUrl as String?,
      localImagePath: localImagePath == _sentinel
          ? this.localImagePath
          : localImagePath as String?,
      compressedBytes: compressedBytes == _sentinel
          ? this.compressedBytes
          : compressedBytes as Uint8List?,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      category:
          category == _sentinel ? this.category : category as ArticleCategory?,
      tags: tags ?? this.tags,
      language: language ?? this.language,
      location:
          location == _sentinel ? this.location : location as ArticleLocation?,
      isPickingImage: isPickingImage ?? this.isPickingImage,
      isPublishing: isPublishing ?? this.isPublishing,
      isPublished: isPublished ?? this.isPublished,
      lastSavedAt:
          lastSavedAt == _sentinel ? this.lastSavedAt : lastSavedAt as DateTime?,
      error: error == _sentinel ? this.error : error as AppException?,
    );
  }

  @override
  List<Object?> get props => [
        draftId,
        editingArticleId,
        existingThumbnailUrl,
        localImagePath,
        compressedBytes,
        title,
        description,
        content,
        category,
        tags,
        language,
        location,
        isPickingImage,
        isPublishing,
        isPublished,
        lastSavedAt,
        error,
      ];
}

const _sentinel = Object();
