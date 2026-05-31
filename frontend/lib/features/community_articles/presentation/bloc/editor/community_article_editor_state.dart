import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/errors/failure.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article_entity.dart';

enum CommunityArticleEditorStatus { initial, submitting, success, failure }

class CommunityArticleEditorState extends Equatable {
  const CommunityArticleEditorState({
    this.status = CommunityArticleEditorStatus.initial,
    this.article,
    this.selectedImageFile,
    this.removeImage = false,
    this.failure,
  });

  final CommunityArticleEditorStatus status;
  final CommunityArticleEntity? article;
  final File? selectedImageFile;
  final bool removeImage;
  final Failure? failure;

  CommunityArticleEditorState copyWith({
    CommunityArticleEditorStatus? status,
    CommunityArticleEntity? article,
    File? selectedImageFile,
    bool? removeImage,
    Failure? failure,
    bool clearFailure = false,
    bool clearSelectedImage = false,
  }) {
    return CommunityArticleEditorState(
      status: status ?? this.status,
      article: article ?? this.article,
      selectedImageFile: clearSelectedImage
          ? null
          : selectedImageFile ?? this.selectedImageFile,
      removeImage: removeImage ?? this.removeImage,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    article,
    selectedImageFile,
    removeImage,
    failure,
  ];
}
