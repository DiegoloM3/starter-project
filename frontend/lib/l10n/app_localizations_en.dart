// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabNews => 'News';

  @override
  String get tabMyArticles => 'My Articles';

  @override
  String get tabSaved => 'Saved';

  @override
  String get tabProfile => 'Profile';

  @override
  String get newArticle => 'New article';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get back => 'Back';

  @override
  String get continueAction => 'Continue';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String byAuthor(String author) {
    return 'By $author';
  }

  @override
  String get savedArticlesTitle => 'Saved Articles';

  @override
  String get articleSaved => 'Article saved successfully.';

  @override
  String get articleRemovedFromSaved => 'Article removed from saved.';

  @override
  String get myArticlesTitle => 'My Articles';

  @override
  String get tapToWriteYourOwn => 'Tap to write your own';

  @override
  String get deleteArticleTitle => 'Delete article';

  @override
  String get cannotBeUndone => 'This action cannot be undone.';

  @override
  String get editArticle => 'Edit article';

  @override
  String get publish => 'Publish';

  @override
  String get chooseCoverImage => 'Choose a cover image';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get unsavedChangesMessage =>
      'You have unsaved changes on this article.';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String get bylineLabel => 'Your name (byline)';

  @override
  String get titleLabel => 'Title';

  @override
  String get summaryLabel => 'Short summary';

  @override
  String get fullContentLabel => 'Full content';

  @override
  String get requiredField => 'Required';

  @override
  String minimumCharacters(int count) {
    return 'Minimum $count characters';
  }

  @override
  String get articleSaveFailed =>
      'Couldn\'t save your article. Please try again.';

  @override
  String get bold => 'Bold';

  @override
  String get subheading => 'Subheading';

  @override
  String get bulletList => 'Bullet list';

  @override
  String get numberedList => 'Numbered list';

  @override
  String get quote => 'Quote';

  @override
  String wordCount(int count) {
    return '$count words';
  }

  @override
  String get write => 'Write';

  @override
  String get preview => 'Preview';

  @override
  String get nothingToPreview => 'Nothing to preview yet.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get guest => 'Guest';

  @override
  String get yourAccount => 'Your account';

  @override
  String get signedIn => 'Signed in';

  @override
  String get articlesOnlyOnThisPhone =>
      'Your articles only live on this phone.';

  @override
  String get keepYourArticles => 'Keep your articles';

  @override
  String get guestExplanation =>
      'You\'re writing as a guest, so your articles only live on this phone. Connect an account to keep them if you reinstall the app or switch phones.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithEmail => 'Continue with email';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get nameLabel => 'Your name';

  @override
  String get editName => 'Edit name';

  @override
  String get nameUpdated => 'Name updated.';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get atLeastSixCharacters => 'At least 6 characters';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutQuestion => 'Sign out?';

  @override
  String get signOutWarning =>
      'You\'ll continue as a guest on this phone. Sign back in anytime to see your articles again.';

  @override
  String get accountConnected => 'Account connected. Your articles are safe.';

  @override
  String get signedInToAccount => 'Signed in to your account.';

  @override
  String get signedOutAsGuest => 'Signed out. You\'re a guest now.';

  @override
  String get accountDeleted => 'Your account and your articles were deleted.';

  @override
  String get alreadyHaveAccountTitle => 'You already have an account';

  @override
  String get alreadyHaveAccountMessage =>
      'This sign-in already belongs to an account. Switch to it? Articles you wrote as a guest on this phone won\'t move with you.';

  @override
  String get switchAccount => 'Switch';

  @override
  String get manageAccount => 'Manage account';

  @override
  String get signedInWith => 'Signed in with';

  @override
  String get guestOnThisPhone => 'Guest on this phone (no account yet)';

  @override
  String get signInGoogle => 'Google';

  @override
  String get signInEmailAndPassword => 'Email and password';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get deleteMyData => 'Delete my data';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteMyDataQuestion => 'Delete my data?';

  @override
  String get deleteAccountQuestion => 'Delete account?';

  @override
  String get deleteMyDataDescription =>
      'Deletes every article you wrote on this phone, with its photos.';

  @override
  String get deleteAccountDescription =>
      'Deletes your account, every article you wrote and their photos.';

  @override
  String get deleteMyDataWarning =>
      'Every article you wrote on this phone and its photos will be deleted. This cannot be undone.';

  @override
  String get deleteAccountWarning =>
      'Your account, every article you wrote and their photos will be deleted. This cannot be undone. You\'ll continue as a guest.';

  @override
  String get confirmItsYou => 'Confirm it\'s you';

  @override
  String get errorWrongCredentials => 'Wrong email or password.';

  @override
  String get errorDifferentAccount =>
      'That\'s a different account. Choose the one you\'re signed in with.';

  @override
  String get errorWeakPassword =>
      'Choose a stronger password (at least 6 characters).';

  @override
  String get errorInvalidEmail => 'That email doesn\'t look right.';

  @override
  String get errorOtherSignInMethod =>
      'This email already signs in another way. Try that option instead.';

  @override
  String get errorMethodNotAvailable =>
      'This sign-in option isn\'t available right now.';

  @override
  String get errorNetwork =>
      'No connection. Check your internet and try again.';

  @override
  String get errorTooManyAttempts =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get privacyAccountTitle => 'Your account';

  @override
  String get privacyAccountBody =>
      'Every install starts with an anonymous id, so the app can tell which articles are yours without asking who you are. If you connect an account, we also keep your email and, with Google, your name and profile photo.';

  @override
  String get privacyArticlesTitle => 'Articles you publish';

  @override
  String get privacyArticlesBody =>
      'The title, summary, body, byline and cover photo of your articles are stored so they can be shown in the app. Articles are public: anyone using the app can read them.';

  @override
  String get privacySavedTitle => 'Saved news';

  @override
  String get privacySavedBody =>
      'News you save stays in a database on this phone only. It never leaves your device, and removing it from Saved deletes it.';

  @override
  String get privacyFeedTitle => 'News feed';

  @override
  String get privacyFeedBody =>
      'Headlines come from NewsAPI. The app asks it for the latest news without sending anything about you.';

  @override
  String get privacyStorageTitle => 'Where it is stored';

  @override
  String get privacyStorageBody =>
      'Your account, articles and photos are stored with Google Firebase (Authentication, Cloud Firestore and Cloud Storage).';

  @override
  String get privacyNeverTitle => 'What we never do';

  @override
  String get privacyNeverBody =>
      'No ads, no analytics or tracking, and your data is never sold or shared with anyone.';

  @override
  String get privacyDeletingTitle => 'Deleting your data';

  @override
  String get privacyDeletingBody =>
      'Profile > Manage account > Delete account removes your account, every article you wrote and their photos, right away.';

  @override
  String get latest => 'LATEST';

  @override
  String get featuredStories => 'FEATURED';

  @override
  String get todaysStories => 'TODAY\'S STORIES';

  @override
  String get readStory => 'Read';

  @override
  String get shareAction => 'Share';

  @override
  String get saveAction => 'Save';

  @override
  String get removeFromSaved => 'Remove from saved';

  @override
  String get allCaughtUp => 'You\'re all caught up';

  @override
  String get allCaughtUpDetail => 'No more news in this section for now.';

  @override
  String get newsLoadFailed => 'Couldn\'t load the news.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get categoryTop => 'Top';

  @override
  String get categoryBusiness => 'Business';

  @override
  String get categoryTechnology => 'Tech';

  @override
  String get categoryScience => 'Science';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: 'Yesterday',
    );
    return '$_temp0';
  }

  @override
  String get savedEmptyTitle => 'Nothing saved yet';

  @override
  String get savedEmptyDetail =>
      'Tap the bookmark on any story to read it later.';

  @override
  String get readFullArticle => 'Read full article';

  @override
  String fullStoryOn(String source) {
    return 'This is the start of the story. The full text is on $source.';
  }

  @override
  String get couldNotOpenArticle => 'Couldn\'t open the article.';

  @override
  String get welcomeTagline =>
      'The day\'s news, and a place to publish your own.';

  @override
  String get welcomeSignInHint => 'Sign in to keep your articles on any phone.';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get connectLater => 'You can connect an account later from Profile.';

  @override
  String get noAccountSignUpWithEmail =>
      'Don\'t have an account? Sign up with email';

  @override
  String get noNewStories => 'No new stories yet';

  @override
  String get refreshFailed => 'Couldn\'t update the news.';

  @override
  String get searchHint => 'Search the news';

  @override
  String get searchAction => 'Search';

  @override
  String get clearSearch => 'Clear';

  @override
  String get searchPromptTitle => 'Search the news';

  @override
  String get searchPromptDetail =>
      'Find stories on any topic from thousands of sources.';

  @override
  String noResultsFor(String query) {
    return 'No results for “$query”';
  }

  @override
  String get noResultsDetail => 'Try other words, or fewer of them.';

  @override
  String get searchFailed => 'Couldn\'t search right now.';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get removeFromHistory => 'Remove from history';

  @override
  String offlineBanner(String time) {
    return 'Offline · news from $time';
  }

  @override
  String get offlineNothingUpdated => 'No connection. Nothing was updated.';

  @override
  String get rateLimitedNothingUpdated =>
      'Today\'s news limit was reached. Nothing was updated.';

  @override
  String newsLimitReachedBanner(String time) {
    return 'Today\'s news limit was reached · news from $time';
  }

  @override
  String get noPhoto => 'No photo';

  @override
  String get saveDraft => 'Save draft';

  @override
  String get draftsTab => 'Drafts';

  @override
  String get publishedTab => 'Published';

  @override
  String get untitledDraft => 'Untitled draft';

  @override
  String get draftBadge => 'Draft';

  @override
  String get draftsEmptyTitle => 'No drafts';

  @override
  String get draftsEmptyDetail =>
      'Articles you save without publishing show up here.';

  @override
  String get publishedEmptyTitle => 'No published articles';

  @override
  String get publishedEmptyDetail =>
      'Finish a draft and publish it to see it here.';

  @override
  String get coverPhotoSection => 'Cover photo';

  @override
  String get articleDetailsSection => 'Article details';

  @override
  String readingTime(int minutes) {
    return '$minutes min read';
  }

  @override
  String get draftAutosaved => 'Draft saved';

  @override
  String maximumCharacters(int count) {
    return 'Maximum $count characters';
  }

  @override
  String get offlineCannotSave =>
      'You\'re offline. Connect to the internet to save this article.';

  @override
  String get couldNotOpenPhotos => 'Couldn\'t open your photos.';

  @override
  String get moveToDrafts => 'Move to drafts';

  @override
  String get moveToDraftsTitle => 'Move to drafts?';

  @override
  String get moveToDraftsMessage =>
      'It stops being public and goes back to your drafts, with the changes you\'ve made. You can publish it again whenever you want.';

  @override
  String get leaveDraftTitle => 'Save your changes?';

  @override
  String get leaveDraftMessage =>
      'Save it as a draft to finish later, publish it now, or discard your changes.';
}
