import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/comment_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_published_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_user_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_draft_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_feed_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/add_comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_comments.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_comment.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_auth_state_changes.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firestore_article_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firebase_storage_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firestore_comment_data_source.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/firebase_auth_data_source.dart';

// Repository mocks
class MockArticleRepository extends Mock implements ArticleRepository {}

class MockCommentRepository extends Mock implements CommentRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

// Use case mocks
class MockGetArticleUseCase extends Mock implements GetArticleUseCase {}

class MockGetSavedArticleUseCase extends Mock
    implements GetSavedArticleUseCase {}

class MockSaveArticleUseCase extends Mock implements SaveArticleUseCase {}

class MockRemoveArticleUseCase extends Mock implements RemoveArticleUseCase {}

class MockCreateArticleUseCase extends Mock implements CreateArticleUseCase {}

class MockUpdateArticleUseCase extends Mock implements UpdateArticleUseCase {}

class MockDeleteArticleUseCase extends Mock implements DeleteArticleUseCase {}

class MockUploadThumbnailUseCase extends Mock
    implements UploadThumbnailUseCase {}

class MockGetPublishedArticlesUseCase extends Mock
    implements GetPublishedArticlesUseCase {}

class MockGetUserArticlesUseCase extends Mock
    implements GetUserArticlesUseCase {}

class MockGetDraftArticlesUseCase extends Mock
    implements GetDraftArticlesUseCase {}

class MockGetFeedArticlesUseCase extends Mock
    implements GetFeedArticlesUseCase {}

class MockAddCommentUseCase extends Mock implements AddCommentUseCase {}

class MockGetCommentsUseCase extends Mock implements GetCommentsUseCase {}

class MockDeleteCommentUseCase extends Mock implements DeleteCommentUseCase {}

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockGetAuthStateChangesUseCase extends Mock
    implements GetAuthStateChangesUseCase {}

// Data source mocks
class MockNewsApiService extends Mock implements NewsApiService {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockArticleDao extends Mock implements ArticleDao {}

class MockFirestoreArticleDataSource extends Mock
    implements FirestoreArticleDataSource {}

class MockFirebaseStorageDataSource extends Mock
    implements FirebaseStorageDataSource {}

class MockFirestoreCommentDataSource extends Mock
    implements FirestoreCommentDataSource {}

class MockFirebaseAuthDataSource extends Mock
    implements FirebaseAuthDataSource {}

// Firebase mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}
