import 'package:equatable/equatable.dart';
import '../../domain/entities/article_upload_entity.dart';

abstract class ArticleUploadState extends Equatable {
  const ArticleUploadState();

  @override
  List<Object?> get props => [];
}

class ArticleUploadInitial extends ArticleUploadState {
  const ArticleUploadInitial();
}

class ArticleUploadThumbnailLoading extends ArticleUploadState {
  const ArticleUploadThumbnailLoading();
}

class ArticleUploadThumbnailReady extends ArticleUploadState {
  final String thumbnailUrl;
  const ArticleUploadThumbnailReady(this.thumbnailUrl);

  @override
  List<Object?> get props => [thumbnailUrl];
}

class ArticleUploading extends ArticleUploadState {
  const ArticleUploading();
}

class ArticleUploadSuccess extends ArticleUploadState {
  final ArticleUploadEntity article;
  const ArticleUploadSuccess(this.article);

  @override
  List<Object?> get props => [article];
}

class ArticleUploadFailure extends ArticleUploadState {
  final String message;
  const ArticleUploadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
