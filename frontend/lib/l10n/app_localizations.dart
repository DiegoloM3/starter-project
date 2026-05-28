import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily News'**
  String get appTitle;

  /// No description provided for @noArticlesYet.
  ///
  /// In en, this message translates to:
  /// **'No articles yet. Be the first to publish!'**
  String get noArticlesYet;

  /// No description provided for @articleSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Article saved successfully.'**
  String get articleSavedSuccessfully;

  /// No description provided for @savedArticles.
  ///
  /// In en, this message translates to:
  /// **'Saved Articles'**
  String get savedArticles;

  /// No description provided for @noSavedArticles.
  ///
  /// In en, this message translates to:
  /// **'No saved articles'**
  String get noSavedArticles;

  /// No description provided for @writeTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Write your title here...'**
  String get writeTitleHint;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @titleMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Title must be under 200 characters'**
  String get titleMaxLength;

  /// No description provided for @attachImage.
  ///
  /// In en, this message translates to:
  /// **'Attach Image'**
  String get attachImage;

  /// No description provided for @briefDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Brief description...'**
  String get briefDescriptionHint;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// No description provided for @descriptionMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Description must be under 500 characters'**
  String get descriptionMaxLength;

  /// No description provided for @addArticleHint.
  ///
  /// In en, this message translates to:
  /// **'Add article here...'**
  String get addArticleHint;

  /// No description provided for @contentRequired.
  ///
  /// In en, this message translates to:
  /// **'Article content is required'**
  String get contentRequired;

  /// No description provided for @articlePublishedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Article published successfully!'**
  String get articlePublishedSuccessfully;

  /// No description provided for @failedToPublishArticle.
  ///
  /// In en, this message translates to:
  /// **'Failed to publish article'**
  String get failedToPublishArticle;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @commentsHeader.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsHeader;

  /// No description provided for @addCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addCommentHint;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first!'**
  String get noCommentsYet;

  /// No description provided for @failedToLoadComments.
  ///
  /// In en, this message translates to:
  /// **'Failed to load comments'**
  String get failedToLoadComments;

  /// No description provided for @unknownAuthor.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownAuthor;

  /// No description provided for @publishArticle.
  ///
  /// In en, this message translates to:
  /// **'Publish Article'**
  String get publishArticle;

  /// No description provided for @myArticles.
  ///
  /// In en, this message translates to:
  /// **'My Articles'**
  String get myArticles;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterDrafts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get filterDrafts;

  /// No description provided for @filterPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get filterPublished;

  /// No description provided for @filterArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get filterArchived;

  /// No description provided for @editDraft.
  ///
  /// In en, this message translates to:
  /// **'Edit Draft'**
  String get editDraft;

  /// No description provided for @newArticle.
  ///
  /// In en, this message translates to:
  /// **'New Article'**
  String get newArticle;

  /// No description provided for @editArticle.
  ///
  /// In en, this message translates to:
  /// **'Edit Article'**
  String get editArticle;

  /// No description provided for @updateArticle.
  ///
  /// In en, this message translates to:
  /// **'Update Article'**
  String get updateArticle;

  /// No description provided for @deleteArticle.
  ///
  /// In en, this message translates to:
  /// **'Delete Article'**
  String get deleteArticle;

  /// No description provided for @deleteArticleConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this article? This action cannot be undone.'**
  String get deleteArticleConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @articleDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Article deleted successfully.'**
  String get articleDeletedSuccessfully;

  /// No description provided for @failedToDeleteArticle.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete article'**
  String get failedToDeleteArticle;

  /// No description provided for @noUserArticles.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t written any articles yet.'**
  String get noUserArticles;

  /// No description provided for @articleUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Article updated successfully!'**
  String get articleUpdatedSuccessfully;

  /// No description provided for @failedToUpdateArticle.
  ///
  /// In en, this message translates to:
  /// **'Failed to update article'**
  String get failedToUpdateArticle;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraft;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @justSaved.
  ///
  /// In en, this message translates to:
  /// **'Just saved'**
  String get justSaved;

  /// No description provided for @savedTimeAgo.
  ///
  /// In en, this message translates to:
  /// **'Saved {time} ago'**
  String savedTimeAgo(String time);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @saveDraftTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get saveDraftTooltip;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search articles...'**
  String get searchHint;

  /// No description provided for @typeToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type to search articles'**
  String get typeToSearch;

  /// No description provided for @noArticlesFound.
  ///
  /// In en, this message translates to:
  /// **'No articles found'**
  String get noArticlesFound;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get searchFailed;

  /// No description provided for @myDrafts.
  ///
  /// In en, this message translates to:
  /// **'My Drafts'**
  String get myDrafts;

  /// No description provided for @noDraftsYet.
  ///
  /// In en, this message translates to:
  /// **'No drafts yet'**
  String get noDraftsYet;

  /// No description provided for @draftsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start writing and your drafts will appear here'**
  String get draftsEmptySubtitle;

  /// No description provided for @failedToLoadDrafts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load drafts'**
  String get failedToLoadDrafts;

  /// No description provided for @deleteDraft.
  ///
  /// In en, this message translates to:
  /// **'Delete Draft'**
  String get deleteDraft;

  /// No description provided for @deleteDraftConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this draft? This cannot be undone.'**
  String get deleteDraftConfirmation;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep Editing'**
  String get keepEditing;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @noContentYet.
  ///
  /// In en, this message translates to:
  /// **'No content yet.'**
  String get noContentYet;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @commentActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete comment action'**
  String get commentActionFailed;

  /// No description provided for @loadArticlesFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load articles'**
  String get loadArticlesFailed;

  /// No description provided for @tapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Tap to retry'**
  String get tapToRetry;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// No description provided for @writeAnArticle.
  ///
  /// In en, this message translates to:
  /// **'Write an article'**
  String get writeAnArticle;

  /// No description provided for @writeTheFirstArticle.
  ///
  /// In en, this message translates to:
  /// **'Write the first article'**
  String get writeTheFirstArticle;

  /// No description provided for @noArticlesTitle.
  ///
  /// In en, this message translates to:
  /// **'No articles yet'**
  String get noArticlesTitle;

  /// No description provided for @noArticlesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your stories will appear here. Start writing something remarkable.'**
  String get noArticlesSubtitle;

  /// No description provided for @noDraftsTitle.
  ///
  /// In en, this message translates to:
  /// **'No drafts'**
  String get noDraftsTitle;

  /// No description provided for @noDraftsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Articles you\'re working on will be saved here automatically.'**
  String get noDraftsSubtitle;

  /// No description provided for @noPublishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing published yet'**
  String get noPublishedTitle;

  /// No description provided for @noPublishedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your work — publish an article to reach your readers.'**
  String get noPublishedSubtitle;

  /// No description provided for @noArchivedTitle.
  ///
  /// In en, this message translates to:
  /// **'No archived articles'**
  String get noArchivedTitle;

  /// No description provided for @noArchivedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Articles you archive will be stored here for reference.'**
  String get noArchivedSubtitle;

  /// No description provided for @noSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved articles'**
  String get noSavedTitle;

  /// No description provided for @noSavedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmark articles you\'d like to read later — they\'ll appear here.'**
  String get noSavedSubtitle;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @articleRemoved.
  ///
  /// In en, this message translates to:
  /// **'Article removed'**
  String get articleRemoved;

  /// No description provided for @draftDeleted.
  ///
  /// In en, this message translates to:
  /// **'Draft deleted'**
  String get draftDeleted;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search for articles'**
  String get searchPrompt;

  /// No description provided for @searchPromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find articles by title or description'**
  String get searchPromptSubtitle;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or check your spelling'**
  String get tryDifferentKeywords;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @couldNotLoadArticles.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the articles. Check your connection and try again.'**
  String get couldNotLoadArticles;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Symmetry'**
  String get appName;

  /// No description provided for @tabFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get tabFeed;

  /// No description provided for @tabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tabSearch;

  /// No description provided for @tabSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get tabSaved;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @sectionLatest.
  ///
  /// In en, this message translates to:
  /// **'LATEST'**
  String get sectionLatest;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @readingTime.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read'**
  String readingTime(int minutes);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
