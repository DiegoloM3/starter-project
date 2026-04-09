import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class CreateArticleParams extends Equatable {
  final ArticleEntity article;
  final File file;

  const CreateArticleParams({
    required this.article,
    required this.file,
  });

  @override
  List<Object?> get props => [
        article,
        file,
      ];
}
