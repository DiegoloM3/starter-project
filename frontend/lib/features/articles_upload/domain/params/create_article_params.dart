import 'dart:io';

import 'package:equatable/equatable.dart';

class CreateArticleParams extends Equatable {
  final String title;
  final String description;
  final String content;
  final String author;
  final File thumbnailFile;
  final String? sourceName;
  final DateTime publishedAt;

  const CreateArticleParams({
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    required this.thumbnailFile,
    this.sourceName,
    required this.publishedAt,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        content,
        author,
        thumbnailFile.path,
        sourceName,
        publishedAt,
      ];
}
