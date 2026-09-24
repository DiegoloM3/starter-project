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

  /// No description provided for @navNews.
  ///
  /// In en, this message translates to:
  /// **'NEWS'**
  String get navNews;

  /// No description provided for @navCommunity.
  ///
  /// In en, this message translates to:
  /// **'COMMUNITY'**
  String get navCommunity;

  /// No description provided for @navSaved.
  ///
  /// In en, this message translates to:
  /// **'SAVED'**
  String get navSaved;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get navAccount;

  /// No description provided for @actionWrite.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get actionWrite;

  /// No description provided for @dailyNewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily News'**
  String get dailyNewsTitle;

  /// No description provided for @newsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not load the news.'**
  String get newsLoadFailed;

  /// No description provided for @newsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No news right now'**
  String get newsEmptyTitle;

  /// No description provided for @newsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this section at the moment. Try another one, or check back in a little while.'**
  String get newsEmptyMessage;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get checkConnection;

  /// No description provided for @categoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// No description provided for @categoryBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get categoryBusiness;

  /// No description provided for @categoryTechnology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
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

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Articles'**
  String get savedTitle;

  /// No description provided for @savedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get savedEmptyTitle;

  /// No description provided for @savedEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Open an article and tap Save to keep it here for later.'**
  String get savedEmptyMessage;

  /// No description provided for @removedFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved.'**
  String get removedFromSaved;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @removeFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get removeFromSaved;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @savedConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Saved. Find it in the Saved tab.'**
  String get savedConfirmation;

  /// No description provided for @articleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This article is no longer available.'**
  String get articleUnavailable;

  /// No description provided for @communityTitle.
  ///
  /// In en, this message translates to:
  /// **'Community Articles'**
  String get communityTitle;

  /// No description provided for @loadMoreArticles.
  ///
  /// In en, this message translates to:
  /// **'Load more articles'**
  String get loadMoreArticles;

  /// No description provided for @communityLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load articles.'**
  String get communityLoadFailed;

  /// No description provided for @communityEmptyRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing new this week'**
  String get communityEmptyRecentTitle;

  /// No description provided for @communityEmptyRecentMessage.
  ///
  /// In en, this message translates to:
  /// **'The community feed shows what was published in the last {days} days. Be the first to write something.'**
  String communityEmptyRecentMessage(int days);

  /// No description provided for @authorEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No articles yet'**
  String get authorEmptyTitle;

  /// No description provided for @authorEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'This journalist has not published anything yet.'**
  String get authorEmptyMessage;

  /// No description provided for @byAuthor.
  ///
  /// In en, this message translates to:
  /// **'By {author}'**
  String byAuthor(String author);

  /// No description provided for @viewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} views'**
  String viewsCount(String count);

  /// No description provided for @moreFrom.
  ///
  /// In en, this message translates to:
  /// **'More from {name}'**
  String moreFrom(String name);

  /// No description provided for @thisAuthor.
  ///
  /// In en, this message translates to:
  /// **'this author'**
  String get thisAuthor;

  /// No description provided for @myArticlesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Articles'**
  String get myArticlesTitle;

  /// No description provided for @searchMyArticles.
  ///
  /// In en, this message translates to:
  /// **'Search in my articles'**
  String get searchMyArticles;

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

  /// No description provided for @badgeDraft.
  ///
  /// In en, this message translates to:
  /// **'DRAFT'**
  String get badgeDraft;

  /// No description provided for @badgePublished.
  ///
  /// In en, this message translates to:
  /// **'PUBLISHED'**
  String get badgePublished;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete article'**
  String get deleteArticleTitle;

  /// No description provided for @deleteArticleMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be deleted permanently. This cannot be undone.'**
  String deleteArticleMessage(String title);

  /// No description provided for @myArticlesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your articles.'**
  String get myArticlesLoadFailed;

  /// No description provided for @noMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get noMatchesTitle;

  /// No description provided for @noMatchesMessage.
  ///
  /// In en, this message translates to:
  /// **'Try another search, or a different filter.'**
  String get noMatchesMessage;

  /// No description provided for @myArticlesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No articles yet'**
  String get myArticlesEmptyTitle;

  /// No description provided for @myArticlesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Everything you write will show up here, drafts included.'**
  String get myArticlesEmptyMessage;

  /// No description provided for @writeFirstArticle.
  ///
  /// In en, this message translates to:
  /// **'Write your first article'**
  String get writeFirstArticle;

  /// No description provided for @publishedOn.
  ///
  /// In en, this message translates to:
  /// **'Published {date}'**
  String publishedOn(String date);

  /// No description provided for @savedOn.
  ///
  /// In en, this message translates to:
  /// **'Saved {date}'**
  String savedOn(String date);

  /// No description provided for @notSavedYet.
  ///
  /// In en, this message translates to:
  /// **'Not saved yet'**
  String get notSavedYet;

  /// No description provided for @newArticle.
  ///
  /// In en, this message translates to:
  /// **'New article'**
  String get newArticle;

  /// No description provided for @editArticle.
  ///
  /// In en, this message translates to:
  /// **'Edit article'**
  String get editArticle;

  /// No description provided for @addCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Add cover image'**
  String get addCoverImage;

  /// No description provided for @recommendedSize.
  ///
  /// In en, this message translates to:
  /// **'Recommended size: 1200 × 630 px'**
  String get recommendedSize;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Write your title here...'**
  String get titleHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add a short description...'**
  String get descriptionHint;

  /// No description provided for @contentHint.
  ///
  /// In en, this message translates to:
  /// **'Start writing your article...'**
  String get contentHint;

  /// No description provided for @articleSection.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get articleSection;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @keepWriting.
  ///
  /// In en, this message translates to:
  /// **'Keep writing'**
  String get keepWriting;

  /// No description provided for @nothingToPreview.
  ///
  /// In en, this message translates to:
  /// **'Nothing to preview yet.'**
  String get nothingToPreview;

  /// No description provided for @draftSavedAt.
  ///
  /// In en, this message translates to:
  /// **'Draft saved · {time}'**
  String draftSavedAt(String time);

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @unsavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your changes are not saved'**
  String get unsavedTitle;

  /// No description provided for @unsavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Leaving now loses what you have written since the last save.'**
  String get unsavedMessage;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @howToWrite.
  ///
  /// In en, this message translates to:
  /// **'How to write an article'**
  String get howToWrite;

  /// No description provided for @toolbarHeading.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get toolbarHeading;

  /// No description provided for @toolbarBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get toolbarBold;

  /// No description provided for @toolbarItalic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get toolbarItalic;

  /// No description provided for @toolbarList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get toolbarList;

  /// No description provided for @toolbarQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get toolbarQuote;

  /// No description provided for @whatYouType.
  ///
  /// In en, this message translates to:
  /// **'What you type'**
  String get whatYouType;

  /// No description provided for @whatReadersSee.
  ///
  /// In en, this message translates to:
  /// **'What readers see'**
  String get whatReadersSee;

  /// No description provided for @tourStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String tourStepOf(int current, int total);

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @tourCoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with a cover'**
  String get tourCoverTitle;

  /// No description provided for @tourCoverBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a picture from your phone. A moving GIF works too, and it is the first thing a reader sees.'**
  String get tourCoverBody;

  /// No description provided for @tourTitleTitle.
  ///
  /// In en, this message translates to:
  /// **'Give it a title'**
  String get tourTitleTitle;

  /// No description provided for @tourTitleBody.
  ///
  /// In en, this message translates to:
  /// **'One line that says what the article is about. You can save a draft with nothing but this.'**
  String get tourTitleBody;

  /// No description provided for @tourFormatTitle.
  ///
  /// In en, this message translates to:
  /// **'Format as you write'**
  String get tourFormatTitle;

  /// No description provided for @tourFormatBody.
  ///
  /// In en, this message translates to:
  /// **'Select some words and press a button. You never have to remember the symbols — these write them for you.'**
  String get tourFormatBody;

  /// No description provided for @tourPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'See it as a reader will'**
  String get tourPreviewTitle;

  /// No description provided for @tourPreviewBody.
  ///
  /// In en, this message translates to:
  /// **'Preview shows the finished article. Switch back whenever you want to keep writing.'**
  String get tourPreviewBody;

  /// No description provided for @tourPublishTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish when it is ready'**
  String get tourPublishTitle;

  /// No description provided for @tourPublishBody.
  ///
  /// In en, this message translates to:
  /// **'Publishing needs a title, a description, a cover and some writing. Until then, Save changes keeps it private.'**
  String get tourPublishBody;

  /// No description provided for @articleLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Your article is live'**
  String get articleLiveTitle;

  /// No description provided for @articleLiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Anyone can now read it in the Community feed.'**
  String get articleLiveMessage;

  /// No description provided for @viewArticle.
  ///
  /// In en, this message translates to:
  /// **'View article'**
  String get viewArticle;

  /// No description provided for @backToMyArticles.
  ///
  /// In en, this message translates to:
  /// **'Back to my articles'**
  String get backToMyArticles;

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

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'I forgot my password'**
  String get forgotPassword;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeatPassword;

  /// No description provided for @displayNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Name readers will see (optional)'**
  String get displayNameOptional;

  /// No description provided for @atLeastCharacters.
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters'**
  String atLeastCharacters(int count);

  /// No description provided for @newHereCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'New here?  Create an account'**
  String get newHereCreateAccount;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @resetRequested.
  ///
  /// In en, this message translates to:
  /// **'Reset requested'**
  String get resetRequested;

  /// No description provided for @resetInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter the email you signed up with and we will send you a link to choose a new password.'**
  String get resetInstructions;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @resetSentMessage.
  ///
  /// In en, this message translates to:
  /// **'If that email has an account, a reset link is on its way. Open it to choose a new password, then come back and sign in.'**
  String get resetSentMessage;

  /// No description provided for @resetSpamHint.
  ///
  /// In en, this message translates to:
  /// **'Hint: Be sure to check your spam or promotions folder if it doesn\'t arrive in a few minutes.'**
  String get resetSpamHint;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @accountInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Write your own stories'**
  String get accountInviteTitle;

  /// No description provided for @accountInviteMessage.
  ///
  /// In en, this message translates to:
  /// **'Reading is always free. An account only takes a moment, and it is what lets you publish.'**
  String get accountInviteMessage;

  /// No description provided for @myArticles.
  ///
  /// In en, this message translates to:
  /// **'My articles'**
  String get myArticles;

  /// No description provided for @nameReadersSee.
  ///
  /// In en, this message translates to:
  /// **'Name readers see'**
  String get nameReadersSee;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @nameHelper.
  ///
  /// In en, this message translates to:
  /// **'Shown as the author of everything you publish next.'**
  String get nameHelper;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @statsSummary.
  ///
  /// In en, this message translates to:
  /// **'{articles}  ·  {views} views'**
  String statsSummary(String articles, String views);

  /// No description provided for @articleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 article} other{{count} articles}}'**
  String articleCount(int count);

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'That email already has an account. Sign in instead.'**
  String get errorEmailInUse;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'That email and password do not match an account.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue.'**
  String get errorNotSignedIn;

  /// No description provided for @errorTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in a few minutes.'**
  String get errorTooManyAttempts;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorGeneric;

  /// No description provided for @errorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get errorEmailRequired;

  /// No description provided for @errorEmailMalformed.
  ///
  /// In en, this message translates to:
  /// **'That does not look like an email address.'**
  String get errorEmailMalformed;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get errorPasswordRequired;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least {count} characters.'**
  String errorPasswordTooShort(int count);

  /// No description provided for @errorPasswordsDiffer.
  ///
  /// In en, this message translates to:
  /// **'The two passwords are different.'**
  String get errorPasswordsDiffer;

  /// No description provided for @errorDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name of up to {count} characters.'**
  String errorDisplayName(int count);

  /// No description provided for @errorTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'The article needs a title.'**
  String get errorTitleRequired;

  /// No description provided for @errorTitleTooLong.
  ///
  /// In en, this message translates to:
  /// **'The title is too long.'**
  String get errorTitleTooLong;

  /// No description provided for @errorDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Readers need a short description.'**
  String get errorDescriptionRequired;

  /// No description provided for @errorDescriptionTooLong.
  ///
  /// In en, this message translates to:
  /// **'The description is too long.'**
  String get errorDescriptionTooLong;

  /// No description provided for @errorContentRequired.
  ///
  /// In en, this message translates to:
  /// **'The article has no content yet.'**
  String get errorContentRequired;

  /// No description provided for @errorThumbnailRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a cover image before publishing.'**
  String get errorThumbnailRequired;

  /// No description provided for @errorAuthorRequired.
  ///
  /// In en, this message translates to:
  /// **'The article has no author.'**
  String get errorAuthorRequired;

  /// No description provided for @errorOwnerRequired.
  ///
  /// In en, this message translates to:
  /// **'The article has no owner.'**
  String get errorOwnerRequired;

  /// No description provided for @errorArticleNotFound.
  ///
  /// In en, this message translates to:
  /// **'This article no longer exists.'**
  String get errorArticleNotFound;

  /// No description provided for @errorArticleNotStored.
  ///
  /// In en, this message translates to:
  /// **'Save the article before publishing it.'**
  String get errorArticleNotStored;

  /// No description provided for @errorImageEmpty.
  ///
  /// In en, this message translates to:
  /// **'The selected image is empty.'**
  String get errorImageEmpty;

  /// No description provided for @errorImageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The image is larger than 5 MB.'**
  String get errorImageTooLarge;

  /// No description provided for @errorImageFormat.
  ///
  /// In en, this message translates to:
  /// **'Only jpg, png, webp and gif images are supported.'**
  String get errorImageFormat;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your connection and try again.'**
  String get errorNoConnection;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Byline'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Read it. Write it.'**
  String get appTagline;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to publish under your own name.'**
  String get signInSubtitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'An account is only needed to write. Reading is always free.'**
  String get signUpSubtitle;

  /// No description provided for @newsPreviewNotice.
  ///
  /// In en, this message translates to:
  /// **'The News API only sends a preview of each article. The full story is at the source.'**
  String get newsPreviewNotice;

  /// No description provided for @openAtSource.
  ///
  /// In en, this message translates to:
  /// **'Read the full article at'**
  String get openAtSource;

  /// No description provided for @bylineUpdated.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your published article now carries the new name.} other{Your {count} published articles now carry the new name.}}'**
  String bylineUpdated(int count);
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
