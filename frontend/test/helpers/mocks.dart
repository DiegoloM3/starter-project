import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_up_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/update_profile.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_assistant_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/draft_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/news_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/saved_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/thumbnail_storage_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/apply_article_lens.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/clear_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_my_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_saved_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_top_headlines.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/load_draft.dart';
import 'package:news_app_clean_architecture/shared/media/domain/use_cases/pick_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/remove_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/search_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/suggest_article_edits.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/update_article.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/save_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/watch_settings.dart';

// Repositories

class MockNewsRepository extends Mock implements NewsRepository {}

class MockArticleAssistantRepository extends Mock implements ArticleAssistantRepository {}

class MockDraftRepository extends Mock implements DraftRepository {}

class MockUserArticleRepository extends Mock implements UserArticleRepository {}

class MockSavedArticleRepository extends Mock implements SavedArticleRepository {}

class MockThumbnailStorageRepository extends Mock
    implements ThumbnailStorageRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

// Use cases (for cubit and widget tests)

class MockWatchAuthStateUseCase extends Mock implements WatchAuthStateUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockSignInWithEmailUseCase extends Mock implements SignInWithEmailUseCase {}

class MockSignInWithGoogleUseCase extends Mock implements SignInWithGoogleUseCase {}

class MockSignUpWithEmailUseCase extends Mock implements SignUpWithEmailUseCase {}

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

class MockWatchSettingsUseCase extends Mock implements WatchSettingsUseCase {}

class MockSaveSettingsUseCase extends Mock implements SaveSettingsUseCase {}

class MockGetFeedUseCase extends Mock implements GetFeedUseCase {}

class MockGetSavedArticlesUseCase extends Mock implements GetSavedArticlesUseCase {}

class MockSaveArticleUseCase extends Mock implements SaveArticleUseCase {}

class MockRemoveSavedArticleUseCase extends Mock implements RemoveSavedArticleUseCase {}

class MockGetMyArticlesUseCase extends Mock implements GetMyArticlesUseCase {}

class MockDeleteArticleUseCase extends Mock implements DeleteArticleUseCase {}

class MockPublishArticleUseCase extends Mock implements PublishArticleUseCase {}

class MockUpdateArticleUseCase extends Mock implements UpdateArticleUseCase {}

class MockPickImageUseCase extends Mock implements PickImageUseCase {}

class MockGetTopHeadlinesUseCase extends Mock implements GetTopHeadlinesUseCase {}

class MockSearchArticlesUseCase extends Mock implements SearchArticlesUseCase {}

class MockSuggestArticleEditsUseCase extends Mock implements SuggestArticleEditsUseCase {}

class MockApplyArticleLensUseCase extends Mock implements ApplyArticleLensUseCase {}

class MockLoadDraftUseCase extends Mock implements LoadDraftUseCase {}

class MockSaveDraftUseCase extends Mock implements SaveDraftUseCase {}

class MockClearDraftUseCase extends Mock implements ClearDraftUseCase {}
