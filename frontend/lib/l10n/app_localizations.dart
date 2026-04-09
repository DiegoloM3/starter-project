import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Shown when an unexpected error occurs during login or other operations
  ///
  /// In en, this message translates to:
  /// **'Something was wrong'**
  String get something_was_wrong;

  /// Displayed when the articles list is empty
  ///
  /// In en, this message translates to:
  /// **'No articles found'**
  String get no_articles_found;

  /// Hint inside a markdown text field prompting user to start typing
  ///
  /// In en, this message translates to:
  /// **'*Tap on the text to start typing'**
  String get tap_to_start_typing;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Hint for the title field when publishing an article
  ///
  /// In en, this message translates to:
  /// **'Write your title here...'**
  String get write_your_title_here;

  /// Hint for the markdown article field when publishing an article
  ///
  /// In en, this message translates to:
  /// **'Add article here...'**
  String get add_article_here;

  /// Label or hint for email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Label or hint for password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Label or hint for name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// App bar title for daily news page
  ///
  /// In en, this message translates to:
  /// **'Daily news'**
  String get daily_news;

  /// Button text to attach an image
  ///
  /// In en, this message translates to:
  /// **'Attach image'**
  String get attach_image;

  /// Button text to publish an article
  ///
  /// In en, this message translates to:
  /// **'Publish article'**
  String get publish_article;

  /// Title for saved articles page
  ///
  /// In en, this message translates to:
  /// **'Saved articles'**
  String get saved_articles;

  /// Snackbar shown after successful publish
  ///
  /// In en, this message translates to:
  /// **'Published article'**
  String get published_article;

  /// Generic error shown in snackbars
  ///
  /// In en, this message translates to:
  /// **'Generic error'**
  String get generic_error;

  /// Shown when a required field is empty
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get required_field;

  /// Snackbar text when article is saved locally
  ///
  /// In en, this message translates to:
  /// **'Saved article'**
  String get saved_article;

  /// Snackbar text when article is deleted locally
  ///
  /// In en, this message translates to:
  /// **'Deleted article'**
  String get deleted_article;

  /// Displayed when there are no saved articles
  ///
  /// In en, this message translates to:
  /// **'No saved articles'**
  String get no_saved_articles;

  /// Generic error text
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Snackbar confirming article removal
  ///
  /// In en, this message translates to:
  /// **'Article removed successfully.'**
  String get article_removed_success;

  /// Snackbar confirming article save
  ///
  /// In en, this message translates to:
  /// **'Article saved successfully.'**
  String get article_saved_success;

  /// Login field error: email required
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get login_field_email_required;

  /// Login field error: email not valid
  ///
  /// In en, this message translates to:
  /// **'Email is not valid'**
  String get login_field_email_not_valid;

  /// Login field error: email already registered
  ///
  /// In en, this message translates to:
  /// **'Email already registered'**
  String get login_field_email_already_registered;

  /// Login field error: password required
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get login_field_password_required;

  /// Login field error: password not valid
  ///
  /// In en, this message translates to:
  /// **'Password is not valid'**
  String get login_field_password_not_valid;

  /// Login field error: invalid credentials
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get login_field_invalid_credentials;

  /// Login field error: unknown error
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get login_field_unknown_error;

  /// Register field error: email required
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get register_field_email_required;

  /// Register field error: email not valid
  ///
  /// In en, this message translates to:
  /// **'Email is not valid'**
  String get register_field_email_not_valid;

  /// Register field error: email already registered
  ///
  /// In en, this message translates to:
  /// **'Email already registered'**
  String get register_field_email_already_registered;

  /// Register field error: name required
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get register_field_name_required;

  /// Register field error: password required
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get register_field_password_required;

  /// Register field error: password not valid
  ///
  /// In en, this message translates to:
  /// **'Password is not valid'**
  String get register_field_password_not_valid;

  /// Register field error: unknown error
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get register_field_unknown_error;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
