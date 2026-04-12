import 'dart:io';

import 'package:equatable/equatable.dart';

class UpdateArticleParams extends Equatable {
  final String id;
  final String title;
  final String description;
  final String content;
  final String author;
  final String? sourceName;
  final DateTime publishedAt;
  final File? newThumbnailFile;

  const UpdateArticleParams({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    this.sourceName,
    required this.publishedAt,
    this.newThumbnailFile,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        author,
        sourceName,
        publishedAt,
        newThumbnailFile?.path,
      ];
}
