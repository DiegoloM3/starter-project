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
/// import 'generated/app_localizations.dart';
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

  /// Application name shown in OS task switcher.
  ///
  /// In en, this message translates to:
  /// **'News App'**
  String get appTitle;

  /// Bottom navigation label for the main feed tab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation label for the settings tab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// App bar title on the home feed.
  ///
  /// In en, this message translates to:
  /// **'Daily News'**
  String get homeTitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterForYou.
  ///
  /// In en, this message translates to:
  /// **'For You'**
  String get filterForYou;

  /// No description provided for @filterForYouEmpty.
  ///
  /// In en, this message translates to:
  /// **'Save a few articles and we\'ll find more like them.'**
  String get filterForYouEmpty;

  /// No description provided for @filterForYouLoading.
  ///
  /// In en, this message translates to:
  /// **'Tailoring picks for you…'**
  String get filterForYouLoading;

  /// Filter chip covering NewsAPI health & wellness articles (fitness/workout/nutrition/wellness/exercise/health keyword search).
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get filterHealth;

  /// No description provided for @filterNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get filterNews;

  /// No description provided for @filterCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get filterCommunity;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search articles…'**
  String get searchHint;

  /// No description provided for @feedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No articles found.'**
  String get feedEmpty;

  /// No description provided for @semanticSearchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Semantic search unavailable — showing keyword matches.'**
  String get semanticSearchUnavailable;

  /// No description provided for @myArticlesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Articles'**
  String get myArticlesTitle;

  /// No description provided for @savedArticlesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Articles'**
  String get savedArticlesTitle;

  /// No description provided for @articleNewsApiTitle.
  ///
  /// In en, this message translates to:
  /// **'NewsAPI Article'**
  String get articleNewsApiTitle;

  /// No description provided for @articleCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Community Article'**
  String get articleCommunityTitle;

  /// No description provided for @savedArticlesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved articles yet.'**
  String get savedArticlesEmpty;

  /// No description provided for @removeAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAction;

  /// No description provided for @articleDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Article not found.'**
  String get articleDetailNotFound;

  /// No description provided for @articleDetailLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load article. Pull back and retry.'**
  String get articleDetailLoadError;

  /// No description provided for @articleSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Article saved successfully.'**
  String get articleSavedSuccess;

  /// No description provided for @newArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'New Article'**
  String get newArticleTitle;

  /// No description provided for @editArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Article'**
  String get editArticleTitle;

  /// No description provided for @saveDraftAction.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraftAction;

  /// No description provided for @publishedSnack.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get publishedSnack;

  /// No description provided for @savedSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedSnack;

  /// No description provided for @publishingOverlay.
  ///
  /// In en, this message translates to:
  /// **'Publishing your article…'**
  String get publishingOverlay;

  /// No description provided for @deleteArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete article?'**
  String get deleteArticleTitle;

  /// No description provided for @deleteArticleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String deleteArticleConfirm(String title);

  /// No description provided for @deleteDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete draft?'**
  String get deleteDraftTitle;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @draftBadge.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draftBadge;

  /// No description provided for @thumbnailPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a thumbnail'**
  String get thumbnailPickerTitle;

  /// No description provided for @thumbnailFromGallery.
  ///
  /// In en, this message translates to:
  /// **'From Gallery'**
  String get thumbnailFromGallery;

  /// No description provided for @thumbnailFromCamera.
  ///
  /// In en, this message translates to:
  /// **'From Camera'**
  String get thumbnailFromCamera;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fieldCategory;

  /// No description provided for @fieldTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get fieldTags;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @menuMyArticles.
  ///
  /// In en, this message translates to:
  /// **'My Articles'**
  String get menuMyArticles;

  /// No description provided for @menuSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get menuSignOut;

  /// No description provided for @authSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInTitle;

  /// No description provided for @authSignInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInAction;

  /// No description provided for @authSignUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignUpTitle;

  /// No description provided for @authSignUpAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignUpAction;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get authDisplayNameLabel;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetPasswordSend.
  ///
  /// In en, this message translates to:
  /// **'Send reset email'**
  String get authResetPasswordSend;

  /// No description provided for @authResetPasswordSent.
  ///
  /// In en, this message translates to:
  /// **'Reset email sent'**
  String get authResetPasswordSent;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get authGoogleSignIn;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow the device language'**
  String get settingsLanguageSystemSubtitle;

  /// No description provided for @settingsPermissionsSection.
  ///
  /// In en, this message translates to:
  /// **'Permissions used by this app'**
  String get settingsPermissionsSection;

  /// No description provided for @settingsPermissionsHelp.
  ///
  /// In en, this message translates to:
  /// **'These permissions are requested only when needed for a specific feature.'**
  String get settingsPermissionsHelp;

  /// No description provided for @permissionCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get permissionCameraTitle;

  /// No description provided for @permissionCameraReason.
  ///
  /// In en, this message translates to:
  /// **'Take a photo to use as your article thumbnail.'**
  String get permissionCameraReason;

  /// No description provided for @permissionPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Library'**
  String get permissionPhotosTitle;

  /// No description provided for @permissionPhotosReason.
  ///
  /// In en, this message translates to:
  /// **'Choose an existing photo as your article thumbnail.'**
  String get permissionPhotosReason;

  /// No description provided for @permissionInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get permissionInternetTitle;

  /// No description provided for @permissionInternetReason.
  ///
  /// In en, this message translates to:
  /// **'Fetch news, sync your articles and run semantic search.'**
  String get permissionInternetReason;
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
