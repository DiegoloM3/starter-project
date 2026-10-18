import 'dart:typed_data';

import 'package:news_app_clean_architecture/features/articles/domain/entities/article_content.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_topic.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_draft.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_image.dart';

ArticleDraft buildValidDraft({String title = 'New title'}) {
  return ArticleDraft(
    title: title,
    description: 'New description',
    content: ArticleContent.fromPlainText('New content'),
    topics: const {ArticleTopic.sports},
  );
}

ArticleDraft buildInvalidDraft() => buildValidDraft(title: '');

ArticleImage buildValidImage() => ArticleImage(Uint8List(10));
