import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/resources/error_type.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/core/resources/image_item.dart';

enum FormStatus { initial, submitting, success, failure }

class NewsFormState extends Equatable {
  final String title;
  final String body;
  final NewsSection? selectedSection;
  final List<ImageItem> images;
  final bool isEditing;
  final String? articleId;
  final FormStatus status;
  final ErrorType? errorType;
  final int maxImages;
  final String originalTitle;
  final String originalBody;
  final NewsSection? originalSection;
  final List<ImageItem> originalImages;

  const NewsFormState({
    this.title = '',
    this.body = '',
    this.selectedSection,
    this.images = const [],
    this.isEditing = false,
    this.articleId,
    this.status = FormStatus.initial,
    this.errorType,
    this.maxImages = 5,
    this.originalTitle = '',
    this.originalBody = '',
    this.originalSection,
    this.originalImages = const [],
  });

  bool get canSubmit =>
      title.trim().isNotEmpty &&
      body.trim().isNotEmpty &&
      selectedSection != null &&
      status != FormStatus.submitting;

  bool get canAddMoreImages => images.length < maxImages;

  bool get hasUnsavedChanges =>
      title != originalTitle ||
      body != originalBody ||
      selectedSection != originalSection ||
      images != originalImages;

  NewsFormState copyWith({
    String? title,
    String? body,
    NewsSection? selectedSection,
    List<ImageItem>? images,
    bool? isEditing,
    String? articleId,
    FormStatus? status,
    ErrorType? errorType,
    int? maxImages,
    String? originalTitle,
    String? originalBody,
    NewsSection? originalSection,
    List<ImageItem>? originalImages,
  }) {
    return NewsFormState(
      title: title ?? this.title,
      body: body ?? this.body,
      selectedSection: selectedSection ?? this.selectedSection,
      images: images ?? this.images,
      isEditing: isEditing ?? this.isEditing,
      articleId: articleId ?? this.articleId,
      status: status ?? this.status,
      errorType: errorType,
      maxImages: maxImages ?? this.maxImages,
      originalTitle: originalTitle ?? this.originalTitle,
      originalBody: originalBody ?? this.originalBody,
      originalSection: originalSection ?? this.originalSection,
      originalImages: originalImages ?? this.originalImages,
    );
  }

  @override
  List<Object?> get props => [
        title,
        body,
        selectedSection,
        images,
        isEditing,
        articleId,
        status,
        errorType,
        maxImages,
        originalTitle,
        originalBody,
        originalSection,
        originalImages,
      ];
}
