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

  /// Title for the daily news home page
  ///
  /// In en, this message translates to:
  /// **'Daily News'**
  String get dailyNewsTitle;

  /// Title for the article detail page
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get articleTitle;

  /// Title for the saved articles page
  ///
  /// In en, this message translates to:
  /// **'Saved Articles'**
  String get savedArticlesTitle;

  /// Empty state message when there are no saved articles
  ///
  /// In en, this message translates to:
  /// **'No saved articles'**
  String get noSavedArticles;

  /// Snackbar message after saving an article
  ///
  /// In en, this message translates to:
  /// **'Article saved successfully.'**
  String get articleSavedSuccess;

  /// Label for the image upload widget
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get uploadImage;

  /// Label for the My News tab on the news list screen
  ///
  /// In en, this message translates to:
  /// **'My News'**
  String get myNewsTab;

  /// Label for the World News tab on the news list screen
  ///
  /// In en, this message translates to:
  /// **'World News'**
  String get worldNewsTab;

  /// Error message when news loading fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load news'**
  String get newsLoadError;

  /// Label for the retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// Empty state message when there are no news articles
  ///
  /// In en, this message translates to:
  /// **'No news available'**
  String get noNewsAvailable;

  /// Accessibility label for the profile avatar button
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileButtonLabel;

  /// Accessibility label for the add news floating action button
  ///
  /// In en, this message translates to:
  /// **'Add news'**
  String get addNewsButtonLabel;

  /// Placeholder text for the news search field
  ///
  /// In en, this message translates to:
  /// **'Search news...'**
  String get searchNewsHint;

  /// Label for the cancel button in search mode
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// Accessibility label for the search button
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButtonLabel;

  /// Label for the All section chip
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get sectionAll;

  /// Label for the Politics section chip
  ///
  /// In en, this message translates to:
  /// **'Politics'**
  String get sectionPolitics;

  /// Label for the Weather section chip
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get sectionWeather;

  /// Label for the Sports section chip
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sectionSports;

  /// Label for the Arts section chip
  ///
  /// In en, this message translates to:
  /// **'Arts'**
  String get sectionArts;

  /// Label for the Crime section chip
  ///
  /// In en, this message translates to:
  /// **'Crime'**
  String get sectionCrime;

  /// Header title for the profile screen
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// Section header for favorites in profile
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesSection;

  /// Section header for saved articles in profile
  ///
  /// In en, this message translates to:
  /// **'Saved for later'**
  String get savedSection;

  /// Label for the favorite action button
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favoriteAction;

  /// Label for the save action button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// Title for the edit profile dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// Label for the name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// Label for the email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Validation message when neither name nor email is provided
  ///
  /// In en, this message translates to:
  /// **'Name or email is required'**
  String get nameOrEmailRequired;

  /// Default display name when no user profile is set
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestName;

  /// Header title for the add news screen
  ///
  /// In en, this message translates to:
  /// **'New Article'**
  String get newNewsTitle;

  /// Header title for the edit news screen
  ///
  /// In en, this message translates to:
  /// **'Edit Article'**
  String get editNewsTitle;

  /// Label for the title field in the news form
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get formTitleLabel;

  /// Label for the section selector in the news form
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get formSectionLabel;

  /// Label for the image gallery in the news form
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get formImagesLabel;

  /// Label for the body field in the news form
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get formBodyLabel;

  /// Placeholder for the title field
  ///
  /// In en, this message translates to:
  /// **'Write the article title...'**
  String get formTitleHint;

  /// Placeholder for the body field
  ///
  /// In en, this message translates to:
  /// **'Write the article content here...'**
  String get formBodyHint;

  /// Hint text for image gallery in create mode
  ///
  /// In en, this message translates to:
  /// **'Add up to {max} photos'**
  String formImageHintCreate(int max);

  /// Hint text showing photo count in edit mode
  ///
  /// In en, this message translates to:
  /// **'{count} of {max} photos'**
  String formImageHintEdit(int count, int max);

  /// Label for the publish button
  ///
  /// In en, this message translates to:
  /// **'Publish Article'**
  String get publishButton;

  /// Label for the save changes button
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesButton;

  /// Title for the discard changes dialog
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// Body text for the discard changes dialog
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to discard them?'**
  String get discardChangesBody;

  /// Label for the discard action button
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardAction;

  /// Title for the delete article dialog
  ///
  /// In en, this message translates to:
  /// **'Delete article?'**
  String get deleteNewsTitle;

  /// Body text for the delete article dialog
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteNewsBody;

  /// Label for the delete action button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// Camera option in image source picker
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get imageSourceCamera;

  /// Gallery option in image source picker
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get imageSourceGallery;

  /// Generic error message shown when no specific error is available
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get genericError;
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
