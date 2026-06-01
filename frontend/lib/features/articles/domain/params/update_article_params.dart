import 'package:equatable/equatable.dart';

class UpdateArticleParams extends Equatable {
  final String articleId;
  final String categoryId;
  final String title;
  final String body;
  final String coverVerticalUrl;
  final String coverHorizontalUrl;
  final int readTimeMinutes;

  const UpdateArticleParams({
    required this.articleId,
    required this.categoryId,
    required this.title,
    required this.body,
    required this.coverVerticalUrl,
    required this.coverHorizontalUrl,
    required this.readTimeMinutes,
  });

  @override
  List<Object?> get props => [
        articleId,
        categoryId,
        title,
        body,
        coverVerticalUrl,
        coverHorizontalUrl,
        readTimeMinutes,
      ];
}
