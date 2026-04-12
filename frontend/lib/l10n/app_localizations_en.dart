// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Daily News';

  @override
  String get myArticles => 'My Articles';

  @override
  String get savedArticles => 'Saved Articles';

  @override
  String get publishArticle => 'Publish Article';

  @override
  String get editArticle => 'Edit Article';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String signedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String signInFailed(String error) {
    return 'Sign-in failed: $error';
  }

  @override
  String get publish => 'Publish';

  @override
  String get publishing => 'Publishing…';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get saving => 'Saving…';

  @override
  String get titleLabel => 'Title';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get contentLabel => 'Content';

  @override
  String get authorLabel => 'Author';

  @override
  String get sourceLabel => 'Source (optional)';

  @override
  String fieldRequired(String field) {
    return '$field is required';
  }

  @override
  String get pickThumbnail => 'Tap to pick a thumbnail';

  @override
  String get thumbnailSelected => 'Thumbnail selected. Tap to change';

  @override
  String get tapToChange => 'Tap to change';

  @override
  String get pleaseSelectThumbnail => 'Please select a thumbnail image';

  @override
  String get articlePublished => 'Article published successfully';

  @override
  String get articleUpdated => 'Article updated successfully';

  @override
  String publishFailed(String reason) {
    return 'Failed: $reason';
  }

  @override
  String get noArticlesYet => 'No articles yet';

  @override
  String get tapPublishHint => 'Tap Publish to share your first story.';

  @override
  String noMatchFor(String query) {
    return 'No articles match \"$query\"';
  }

  @override
  String get deleteArticle => 'Delete article?';

  @override
  String get deleteConfirm => 'This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get publishNewArticle => 'Publish a new article';

  @override
  String get editThisArticle => 'Edit this article';

  @override
  String get saveArticle => 'Save article';

  @override
  String get removeFromSaved => 'Remove from saved';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get searchHint => 'Search title, description, author…';

  @override
  String get searchLabel =>
      'Search your articles by title, description, or author';

  @override
  String get retry => 'Retry';

  @override
  String get onboardingTitle1 => 'Welcome, Journalist!';

  @override
  String get onboardingBody1 =>
      'This app lets you read the latest news from around the world and publish your own articles for everyone to see.';

  @override
  String get onboardingTitle2 => 'Publish Your Stories';

  @override
  String get onboardingBody2 =>
      'Tap the + button or visit \"My Articles\" to write, edit, and manage your publications with images, rich descriptions, and real-time sync to the cloud.';

  @override
  String get onboardingTitle3 => 'Works Offline';

  @override
  String get onboardingBody3 =>
      'Your articles are cached locally so you can browse them even without internet. Edits sync automatically when you\'re back online.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get articleSaved => 'Article saved successfully.';

  @override
  String get noSavedArticles => 'NO SAVED ARTICLES';

  @override
  String get publishArticleA11y => 'Publish article';

  @override
  String get publishingA11y => 'Publishing article, please wait';

  @override
  String get loginSubtitle =>
      'Sign in with your Google account to start publishing articles.';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signingIn => 'Signing in…';

  @override
  String get changeLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';
}
