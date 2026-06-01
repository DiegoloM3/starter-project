import 'package:equatable/equatable.dart';

class PublishArticleParams extends Equatable {
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final String categoryId;
  final String title;
  final String body;
  final String coverVerticalUrl;
  final String coverHorizontalUrl;
  final int readTimeMinutes;

  const PublishArticleParams({
    required this.authorId,
    this.authorName = '',
    this.authorAvatarUrl = '',
    required this.categoryId,
    required this.title,
    required this.body,
    required this.coverVerticalUrl,
    required this.coverHorizontalUrl,
    this.readTimeMinutes = 1,
  });

  @override
  List<Object?> get props => [
        authorId,
        authorName,
        authorAvatarUrl,
        categoryId,
        title,
        body,
        coverVerticalUrl,
        coverHorizontalUrl,
        readTimeMinutes,
      ];
}
