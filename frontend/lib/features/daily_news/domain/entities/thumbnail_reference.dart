import 'package:equatable/equatable.dart';

/// Where an uploaded article thumbnail lives.
class ThumbnailReference extends Equatable {
  /// Public download URL, used to render the image.
  final String url;

  /// Object path inside the storage bucket, used to delete or replace it.
  final String path;

  const ThumbnailReference({required this.url, required this.path});

  @override
  List<Object?> get props => [url, path];
}
