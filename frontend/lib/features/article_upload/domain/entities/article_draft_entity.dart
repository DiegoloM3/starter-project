import 'package:equatable/equatable.dart';

class ArticleDraftEntity extends Equatable {
  final String title;
  final String content;
  final List<String> tags;
  final String? thumbnailLocalPath;
  final DateTime updatedAt;

  const ArticleDraftEntity({
    required this.title,
    required this.content,
    required this.tags,
    this.thumbnailLocalPath,
    required this.updatedAt,
  });

  bool get isEmpty => title.isEmpty && content.isEmpty && tags.isEmpty;

  @override
  List<Object?> get props => [title, content, tags, thumbnailLocalPath, updatedAt];
}
