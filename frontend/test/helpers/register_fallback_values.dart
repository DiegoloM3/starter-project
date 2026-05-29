import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_comment.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up.dart';

void registerTestFallbackValues() {
  registerFallbackValue(const ArticleEntity());
  registerFallbackValue(const CommentEntity());
  registerFallbackValue(const ArticleModel());
  registerFallbackValue(const CommentModel());
  registerFallbackValue(
    const UploadThumbnailParams(articleId: '', filePath: ''),
  );
  registerFallbackValue(
    const DeleteCommentParams(articleId: '', commentId: ''),
  );
  registerFallbackValue(
    const SignInParams(email: '', password: ''),
  );
  registerFallbackValue(
    const SignUpParams(email: '', password: '', displayName: ''),
  );
}
