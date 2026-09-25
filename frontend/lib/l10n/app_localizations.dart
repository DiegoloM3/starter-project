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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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

  /// No description provided for @tabNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get tabNews;

  /// No description provided for @tabMyArticles.
  ///
  /// In en, this message translates to:
  /// **'My Articles'**
  String get tabMyArticles;

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

  /// No description provided for @newArticle.
  ///
  /// In en, this message translates to:
  /// **'New article'**
  String get newArticle;

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

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @byAuthor.
  ///
  /// In en, this message translates to:
  /// **'By {author}'**
  String byAuthor(String author);

  /// No description provided for @savedArticlesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Articles'**
  String get savedArticlesTitle;

  /// No description provided for @articleSaved.
  ///
  /// In en, this message translates to:
  /// **'Article saved successfully.'**
  String get articleSaved;

  /// No description provided for @articleRemovedFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Article removed from saved.'**
  String get articleRemovedFromSaved;

  /// No description provided for @myArticlesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Articles'**
  String get myArticlesTitle;

  /// No description provided for @tapToWriteYourOwn.
  ///
  /// In en, this message translates to:
  /// **'Tap to write your own'**
  String get tapToWriteYourOwn;

  /// No description provided for @deleteArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete article'**
  String get deleteArticleTitle;

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get cannotBeUndone;

  /// No description provided for @editArticle.
  ///
  /// In en, this message translates to:
  /// **'Edit article'**
  String get editArticle;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @chooseCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Choose a cover image'**
  String get chooseCoverImage;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @unsavedChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes on this article.'**
  String get unsavedChangesMessage;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @bylineLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name (byline)'**
  String get bylineLabel;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @summaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Short summary'**
  String get summaryLabel;

  /// No description provided for @fullContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Full content'**
  String get fullContentLabel;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @minimumCharacters.
  ///
  /// In en, this message translates to:
  /// **'Minimum {count} characters'**
  String minimumCharacters(int count);

  /// No description provided for @articleSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your article. Please try again.'**
  String get articleSaveFailed;

  /// No description provided for @bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// No description provided for @subheading.
  ///
  /// In en, this message translates to:
  /// **'Subheading'**
  String get subheading;

  /// No description provided for @bulletList.
  ///
  /// In en, this message translates to:
  /// **'Bullet list'**
  String get bulletList;

  /// No description provided for @numberedList.
  ///
  /// In en, this message translates to:
  /// **'Numbered list'**
  String get numberedList;

  /// No description provided for @quote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get quote;

  /// No description provided for @wordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String wordCount(int count);

  /// No description provided for @write.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get write;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @nothingToPreview.
  ///
  /// In en, this message translates to:
  /// **'Nothing to preview yet.'**
  String get nothingToPreview;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @yourAccount.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get yourAccount;

  /// No description provided for @signedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedIn;

  /// No description provided for @articlesOnlyOnThisPhone.
  ///
  /// In en, this message translates to:
  /// **'Your articles only live on this phone.'**
  String get articlesOnlyOnThisPhone;

  /// No description provided for @keepYourArticles.
  ///
  /// In en, this message translates to:
  /// **'Keep your articles'**
  String get keepYourArticles;

  /// No description provided for @guestExplanation.
  ///
  /// In en, this message translates to:
  /// **'You\'re writing as a guest, so your articles only live on this phone. Connect an account to keep them if you reinstall the app or switch phones.'**
  String get guestExplanation;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get continueWithEmail;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get nameLabel;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get editName;

  /// No description provided for @nameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated.'**
  String get nameUpdated;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @atLeastSixCharacters.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get atLeastSixCharacters;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutQuestion;

  /// No description provided for @signOutWarning.
  ///
  /// In en, this message translates to:
  /// **'You\'ll continue as a guest on this phone. Sign back in anytime to see your articles again.'**
  String get signOutWarning;

  /// No description provided for @accountConnected.
  ///
  /// In en, this message translates to:
  /// **'Account connected. Your articles are safe.'**
  String get accountConnected;

  /// No description provided for @signedInToAccount.
  ///
  /// In en, this message translates to:
  /// **'Signed in to your account.'**
  String get signedInToAccount;

  /// No description provided for @signedOutAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Signed out. You\'re a guest now.'**
  String get signedOutAsGuest;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account and your articles were deleted.'**
  String get accountDeleted;

  /// No description provided for @alreadyHaveAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'You already have an account'**
  String get alreadyHaveAccountTitle;

  /// No description provided for @alreadyHaveAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This sign-in already belongs to an account. Switch to it? Articles you wrote as a guest on this phone won\'t move with you.'**
  String get alreadyHaveAccountMessage;

  /// No description provided for @switchAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchAccount;

  /// No description provided for @manageAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage account'**
  String get manageAccount;

  /// No description provided for @signedInWith.
  ///
  /// In en, this message translates to:
  /// **'Signed in with'**
  String get signedInWith;

  /// No description provided for @guestOnThisPhone.
  ///
  /// In en, this message translates to:
  /// **'Guest on this phone (no account yet)'**
  String get guestOnThisPhone;

  /// No description provided for @signInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get signInGoogle;

  /// No description provided for @signInEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Email and password'**
  String get signInEmailAndPassword;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @deleteMyData.
  ///
  /// In en, this message translates to:
  /// **'Delete my data'**
  String get deleteMyData;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteMyDataQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete my data?'**
  String get deleteMyDataQuestion;

  /// No description provided for @deleteAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountQuestion;

  /// No description provided for @deleteMyDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Deletes every article you wrote on this phone, with its photos.'**
  String get deleteMyDataDescription;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Deletes your account, every article you wrote and their photos.'**
  String get deleteAccountDescription;

  /// No description provided for @deleteMyDataWarning.
  ///
  /// In en, this message translates to:
  /// **'Every article you wrote on this phone and its photos will be deleted. This cannot be undone.'**
  String get deleteMyDataWarning;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Your account, every article you wrote and their photos will be deleted. This cannot be undone. You\'ll continue as a guest.'**
  String get deleteAccountWarning;

  /// No description provided for @confirmItsYou.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you'**
  String get confirmItsYou;

  /// No description provided for @errorWrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get errorWrongCredentials;

  /// No description provided for @errorDifferentAccount.
  ///
  /// In en, this message translates to:
  /// **'That\'s a different account. Choose the one you\'re signed in with.'**
  String get errorDifferentAccount;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password (at least 6 characters).'**
  String get errorWeakPassword;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'That email doesn\'t look right.'**
  String get errorInvalidEmail;

  /// No description provided for @errorOtherSignInMethod.
  ///
  /// In en, this message translates to:
  /// **'This email already signs in another way. Try that option instead.'**
  String get errorOtherSignInMethod;

  /// No description provided for @errorMethodNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This sign-in option isn\'t available right now.'**
  String get errorMethodNotAvailable;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get errorNetwork;

  /// No description provided for @errorTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a moment and try again.'**
  String get errorTooManyAttempts;

  /// No description provided for @privacyAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get privacyAccountTitle;

  /// No description provided for @privacyAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Every install starts with an anonymous id, so the app can tell which articles are yours without asking who you are. If you connect an account, we also keep your email and, with Google, your name and profile photo.'**
  String get privacyAccountBody;

  /// No description provided for @privacyArticlesTitle.
  ///
  /// In en, this message translates to:
  /// **'Articles you publish'**
  String get privacyArticlesTitle;

  /// No description provided for @privacyArticlesBody.
  ///
  /// In en, this message translates to:
  /// **'The title, summary, body, byline and cover photo of your articles are stored so they can be shown in the app. Articles are public: anyone using the app can read them.'**
  String get privacyArticlesBody;

  /// No description provided for @privacySavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved news'**
  String get privacySavedTitle;

  /// No description provided for @privacySavedBody.
  ///
  /// In en, this message translates to:
  /// **'News you save stays in a database on this phone only. It never leaves your device, and removing it from Saved deletes it.'**
  String get privacySavedBody;

  /// No description provided for @privacyFeedTitle.
  ///
  /// In en, this message translates to:
  /// **'News feed'**
  String get privacyFeedTitle;

  /// No description provided for @privacyFeedBody.
  ///
  /// In en, this message translates to:
  /// **'Headlines come from NewsAPI. The app asks it for the latest news without sending anything about you.'**
  String get privacyFeedBody;

  /// No description provided for @privacyStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Where it is stored'**
  String get privacyStorageTitle;

  /// No description provided for @privacyStorageBody.
  ///
  /// In en, this message translates to:
  /// **'Your account, articles and photos are stored with Google Firebase (Authentication, Cloud Firestore and Cloud Storage).'**
  String get privacyStorageBody;

  /// No description provided for @privacyNeverTitle.
  ///
  /// In en, this message translates to:
  /// **'What we never do'**
  String get privacyNeverTitle;

  /// No description provided for @privacyNeverBody.
  ///
  /// In en, this message translates to:
  /// **'No ads, no analytics or tracking, and your data is never sold or shared with anyone.'**
  String get privacyNeverBody;

  /// No description provided for @privacyDeletingTitle.
  ///
  /// In en, this message translates to:
  /// **'Deleting your data'**
  String get privacyDeletingTitle;

  /// No description provided for @privacyDeletingBody.
  ///
  /// In en, this message translates to:
  /// **'Profile > Manage account > Delete account removes your account, every article you wrote and their photos, right away.'**
  String get privacyDeletingBody;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'LATEST'**
  String get latest;

  /// No description provided for @featuredStories.
  ///
  /// In en, this message translates to:
  /// **'FEATURED'**
  String get featuredStories;

  /// No description provided for @todaysStories.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S STORIES'**
  String get todaysStories;

  /// No description provided for @readStory.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readStory;

  /// No description provided for @shareAction.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAction;

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @removeFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get removeFromSaved;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get allCaughtUp;

  /// No description provided for @allCaughtUpDetail.
  ///
  /// In en, this message translates to:
  /// **'No more news in this section for now.'**
  String get allCaughtUpDetail;

  /// No description provided for @newsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the news.'**
  String get newsLoadFailed;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @categoryTop.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get categoryTop;

  /// No description provided for @categoryBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get categoryBusiness;

  /// No description provided for @categoryTechnology.
  ///
  /// In en, this message translates to:
  /// **'Tech'**
  String get categoryTechnology;

  /// No description provided for @categoryScience.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get categoryScience;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categorySports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get categorySports;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Yesterday} other{{count} days ago}}'**
  String daysAgo(int count);

  /// No description provided for @savedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get savedEmptyTitle;

  /// No description provided for @savedEmptyDetail.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark on any story to read it later.'**
  String get savedEmptyDetail;

  /// No description provided for @readFullArticle.
  ///
  /// In en, this message translates to:
  /// **'Read full article'**
  String get readFullArticle;

  /// No description provided for @fullStoryOn.
  ///
  /// In en, this message translates to:
  /// **'This is the start of the story. The full text is on {source}.'**
  String fullStoryOn(String source);

  /// No description provided for @couldNotOpenArticle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the article.'**
  String get couldNotOpenArticle;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'The day\'s news, and a place to publish your own.'**
  String get welcomeTagline;

  /// No description provided for @welcomeSignInHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep your articles on any phone.'**
  String get welcomeSignInHint;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @connectLater.
  ///
  /// In en, this message translates to:
  /// **'You can connect an account later from Profile.'**
  String get connectLater;

  /// No description provided for @noAccountSignUpWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up with email'**
  String get noAccountSignUpWithEmail;

  /// No description provided for @noNewStories.
  ///
  /// In en, this message translates to:
  /// **'No new stories yet'**
  String get noNewStories;

  /// No description provided for @refreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the news.'**
  String get refreshFailed;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search the news'**
  String get searchHint;

  /// No description provided for @searchAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchAction;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearSearch;

  /// No description provided for @searchPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Search the news'**
  String get searchPromptTitle;

  /// No description provided for @searchPromptDetail.
  ///
  /// In en, this message translates to:
  /// **'Find stories on any topic from thousands of sources.'**
  String get searchPromptDetail;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for “{query}”'**
  String noResultsFor(String query);

  /// No description provided for @noResultsDetail.
  ///
  /// In en, this message translates to:
  /// **'Try other words, or fewer of them.'**
  String get noResultsDetail;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t search right now.'**
  String get searchFailed;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @removeFromHistory.
  ///
  /// In en, this message translates to:
  /// **'Remove from history'**
  String get removeFromHistory;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline · news from {time}'**
  String offlineBanner(String time);

  /// No description provided for @offlineNothingUpdated.
  ///
  /// In en, this message translates to:
  /// **'No connection. Nothing was updated.'**
  String get offlineNothingUpdated;

  /// No description provided for @rateLimitedNothingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Today\'s news limit was reached. Nothing was updated.'**
  String get rateLimitedNothingUpdated;

  /// No description provided for @newsLimitReachedBanner.
  ///
  /// In en, this message translates to:
  /// **'Today\'s news limit was reached · news from {time}'**
  String newsLimitReachedBanner(String time);

  /// No description provided for @noPhoto.
  ///
  /// In en, this message translates to:
  /// **'No photo'**
  String get noPhoto;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get saveDraft;

  /// No description provided for @draftsTab.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get draftsTab;

  /// No description provided for @publishedTab.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get publishedTab;

  /// No description provided for @untitledDraft.
  ///
  /// In en, this message translates to:
  /// **'Untitled draft'**
  String get untitledDraft;

  /// No description provided for @draftBadge.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draftBadge;

  /// No description provided for @draftsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No drafts'**
  String get draftsEmptyTitle;

  /// No description provided for @draftsEmptyDetail.
  ///
  /// In en, this message translates to:
  /// **'Articles you save without publishing show up here.'**
  String get draftsEmptyDetail;

  /// No description provided for @publishedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No published articles'**
  String get publishedEmptyTitle;

  /// No description provided for @publishedEmptyDetail.
  ///
  /// In en, this message translates to:
  /// **'Finish a draft and publish it to see it here.'**
  String get publishedEmptyDetail;

  /// No description provided for @coverPhotoSection.
  ///
  /// In en, this message translates to:
  /// **'Cover photo'**
  String get coverPhotoSection;

  /// No description provided for @articleDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Article details'**
  String get articleDetailsSection;

  /// No description provided for @readingTime.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read'**
  String readingTime(int minutes);

  /// No description provided for @draftAutosaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get draftAutosaved;

  /// No description provided for @maximumCharacters.
  ///
  /// In en, this message translates to:
  /// **'Maximum {count} characters'**
  String maximumCharacters(int count);

  /// No description provided for @offlineCannotSave.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Connect to the internet to save this article.'**
  String get offlineCannotSave;

  /// No description provided for @couldNotOpenPhotos.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open your photos.'**
  String get couldNotOpenPhotos;

  /// No description provided for @moveToDrafts.
  ///
  /// In en, this message translates to:
  /// **'Move to drafts'**
  String get moveToDrafts;

  /// No description provided for @moveToDraftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Move to drafts?'**
  String get moveToDraftsTitle;

  /// No description provided for @moveToDraftsMessage.
  ///
  /// In en, this message translates to:
  /// **'It stops being public and goes back to your drafts, with the changes you\'ve made. You can publish it again whenever you want.'**
  String get moveToDraftsMessage;

  /// No description provided for @leaveDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Save your changes?'**
  String get leaveDraftTitle;

  /// No description provided for @leaveDraftMessage.
  ///
  /// In en, this message translates to:
  /// **'Save it as a draft to finish later, publish it now, or discard your changes.'**
  String get leaveDraftMessage;
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
