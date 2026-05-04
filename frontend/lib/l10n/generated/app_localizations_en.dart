// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'News App';

  @override
  String get navHome => 'Home';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeTitle => 'Daily News';

  @override
  String get filterAll => 'All';

  @override
  String get filterForYou => 'For You';

  @override
  String get filterForYouEmpty =>
      'Save a few articles and we\'ll find more like them.';

  @override
  String get filterForYouLoading => 'Tailoring picks for you…';

  @override
  String get filterHealth => 'Health';

  @override
  String get filterNews => 'News';

  @override
  String get filterCommunity => 'Community';

  @override
  String get searchHint => 'Search articles…';

  @override
  String get feedEmpty => 'No articles found.';

  @override
  String get semanticSearchUnavailable =>
      'Semantic search unavailable — showing keyword matches.';

  @override
  String get myArticlesTitle => 'My Articles';

  @override
  String get savedArticlesTitle => 'Saved Articles';

  @override
  String get articleNewsApiTitle => 'NewsAPI Article';

  @override
  String get articleCommunityTitle => 'Community Article';

  @override
  String get savedArticlesEmpty => 'No saved articles yet.';

  @override
  String get removeAction => 'Remove';

  @override
  String get articleDetailNotFound => 'Article not found.';

  @override
  String get articleDetailLoadError =>
      'Couldn\'t load article. Pull back and retry.';

  @override
  String get articleSavedSuccess => 'Article saved successfully.';

  @override
  String get newArticleTitle => 'New Article';

  @override
  String get editArticleTitle => 'Edit Article';

  @override
  String get saveDraftAction => 'Save Draft';

  @override
  String get publishedSnack => 'Published';

  @override
  String get savedSnack => 'Saved';

  @override
  String get publishingOverlay => 'Publishing your article…';

  @override
  String get deleteArticleTitle => 'Delete article?';

  @override
  String deleteArticleConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get deleteDraftTitle => 'Delete draft?';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get draftBadge => 'Draft';

  @override
  String get thumbnailPickerTitle => 'Pick a thumbnail';

  @override
  String get thumbnailFromGallery => 'From Gallery';

  @override
  String get thumbnailFromCamera => 'From Camera';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldTags => 'Tags';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get menuMyArticles => 'My Articles';

  @override
  String get menuSignOut => 'Sign out';

  @override
  String get authSignInTitle => 'Sign in';

  @override
  String get authSignInAction => 'Sign in';

  @override
  String get authSignUpTitle => 'Create account';

  @override
  String get authSignUpAction => 'Create account';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authDisplayNameLabel => 'Display name';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authResetPasswordTitle => 'Reset password';

  @override
  String get authResetPasswordSend => 'Send reset email';

  @override
  String get authResetPasswordSent => 'Reset email sent';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authGoogleSignIn => 'Sign in with Google';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageSystemSubtitle => 'Follow the device language';

  @override
  String get settingsPermissionsSection => 'Permissions used by this app';

  @override
  String get settingsPermissionsHelp =>
      'These permissions are requested only when needed for a specific feature.';

  @override
  String get permissionCameraTitle => 'Camera';

  @override
  String get permissionCameraReason =>
      'Take a photo to use as your article thumbnail.';

  @override
  String get permissionPhotosTitle => 'Photo Library';

  @override
  String get permissionPhotosReason =>
      'Choose an existing photo as your article thumbnail.';

  @override
  String get permissionInternetTitle => 'Internet';

  @override
  String get permissionInternetReason =>
      'Fetch news, sync your articles and run semantic search.';
}
