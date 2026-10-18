import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/repository/comment_repository.dart';

class MockCommentRepository extends Mock implements CommentRepository {}

final CommentEntity testComment = CommentEntity(
  id: 'comment-1',
  articleId: 'article-1',
  authorId: 'user-1',
  authorName: 'Jane Doe',
  text: 'Great article',
  createdAt: DateTime(2026, 10, 17),
);
