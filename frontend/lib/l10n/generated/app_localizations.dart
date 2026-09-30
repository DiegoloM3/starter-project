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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
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

  /// No description provided for @topNewsTab.
  ///
  /// In en, this message translates to:
  /// **'Top news'**
  String get topNewsTab;

  /// No description provided for @communityTab.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get communityTab;

  /// No description provided for @publishAnArticle.
  ///
  /// In en, this message translates to:
  /// **'Publish an article'**
  String get publishAnArticle;

  /// No description provided for @savedArticles.
  ///
  /// In en, this message translates to:
  /// **'Saved articles'**
  String get savedArticles;

  /// No description provided for @savedArticlesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Articles'**
  String get savedArticlesTitle;

  /// No description provided for @noSavedArticles.
  ///
  /// In en, this message translates to:
  /// **'NO SAVED ARTICLES'**
  String get noSavedArticles;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @articlePublished.
  ///
  /// In en, this message translates to:
  /// **'Your article has been published.'**
  String get articlePublished;

  /// No description provided for @articleSaved.
  ///
  /// In en, this message translates to:
  /// **'Article saved successfully.'**
  String get articleSaved;

  /// No description provided for @articlesCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'The articles could not be loaded.'**
  String get articlesCouldNotLoad;

  /// No description provided for @noArticlesYet.
  ///
  /// In en, this message translates to:
  /// **'No articles yet. Be the first journalist to publish one!'**
  String get noArticlesYet;

  /// No description provided for @writeAnArticle.
  ///
  /// In en, this message translates to:
  /// **'Write an article'**
  String get writeAnArticle;

  /// Estimated time to read an article, next to its author and date.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read'**
  String readingTime(int minutes);

  /// No description provided for @listenToArticle.
  ///
  /// In en, this message translates to:
  /// **'Listen to this article'**
  String get listenToArticle;

  /// No description provided for @stopReading.
  ///
  /// In en, this message translates to:
  /// **'Stop reading'**
  String get stopReading;

  /// No description provided for @readingProgress.
  ///
  /// In en, this message translates to:
  /// **'Reading progress'**
  String get readingProgress;

  /// No description provided for @cannotReadAloud.
  ///
  /// In en, this message translates to:
  /// **'This device cannot read aloud. Check the text-to-speech settings of your phone.'**
  String get cannotReadAloud;

  /// No description provided for @publishArticle.
  ///
  /// In en, this message translates to:
  /// **'Publish Article'**
  String get publishArticle;

  /// No description provided for @publishing.
  ///
  /// In en, this message translates to:
  /// **'Publishing…'**
  String get publishing;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Write your title here…'**
  String get titleHint;

  /// No description provided for @authorLabel.
  ///
  /// In en, this message translates to:
  /// **'Written by'**
  String get authorLabel;

  /// No description provided for @authorHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get authorHint;

  /// No description provided for @contentHint.
  ///
  /// In en, this message translates to:
  /// **'Add article here… Use the toolbar for **bold** text and ## subtitles.'**
  String get contentHint;

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

  /// Markdown shown in the preview while the article is empty.
  ///
  /// In en, this message translates to:
  /// **'*Nothing to preview yet.*'**
  String get nothingToPreview;

  /// No description provided for @bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// No description provided for @italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italic;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get subtitle;

  /// No description provided for @bulletedList.
  ///
  /// In en, this message translates to:
  /// **'Bulleted list'**
  String get bulletedList;

  /// Live statistics under the article being written.
  ///
  /// In en, this message translates to:
  /// **'{words, plural, =1{1 word} other{{words} words}} · {minutes} min read'**
  String writingStats(int words, int minutes);

  /// What screen readers say for the 12/100 counter of a text field.
  ///
  /// In en, this message translates to:
  /// **'{length} of {maxLength} characters used'**
  String charactersUsed(int length, int maxLength);

  /// No description provided for @attachImage.
  ///
  /// In en, this message translates to:
  /// **'Attach Image'**
  String get attachImage;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get changeImage;

  /// No description provided for @articleImageHint.
  ///
  /// In en, this message translates to:
  /// **'Article image. Double tap to choose another one.'**
  String get articleImageHint;

  /// No description provided for @draftRestored.
  ///
  /// In en, this message translates to:
  /// **'We restored the article you left unfinished.'**
  String get draftRestored;

  /// No description provided for @startOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get startOver;

  /// No description provided for @saveDraftQuestion.
  ///
  /// In en, this message translates to:
  /// **'Save this article as a draft?'**
  String get saveDraftQuestion;

  /// No description provided for @saveDraftExplanation.
  ///
  /// In en, this message translates to:
  /// **'You can finish it the next time you tap +.'**
  String get saveDraftExplanation;

  /// No description provided for @keepWriting.
  ///
  /// In en, this message translates to:
  /// **'Keep writing'**
  String get keepWriting;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get saveDraft;

  /// No description provided for @publishFailed.
  ///
  /// In en, this message translates to:
  /// **'Your article could not be published. Check your connection and try again.'**
  String get publishFailed;

  /// No description provided for @galleryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The gallery could not be opened. Check the app permissions and try again.'**
  String get galleryUnavailable;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @titleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add a title for your article.'**
  String get titleEmpty;

  /// No description provided for @titleTooLong.
  ///
  /// In en, this message translates to:
  /// **'The title can have up to {maxLength} characters.'**
  String titleTooLong(int maxLength);

  /// No description provided for @authorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Sign the article with your name.'**
  String get authorEmpty;

  /// No description provided for @authorTooLong.
  ///
  /// In en, this message translates to:
  /// **'Your name can have up to {maxLength} characters.'**
  String authorTooLong(int maxLength);

  /// No description provided for @contentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Write your article before publishing it.'**
  String get contentEmpty;

  /// No description provided for @contentTooLong.
  ///
  /// In en, this message translates to:
  /// **'The article can have up to {maxLength} characters.'**
  String contentTooLong(int maxLength);

  /// No description provided for @thumbnailMissing.
  ///
  /// In en, this message translates to:
  /// **'Attach an image to illustrate your article.'**
  String get thumbnailMissing;

  /// No description provided for @thumbnailUnsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Choose a JPG, PNG or WebP image.'**
  String get thumbnailUnsupportedFormat;

  /// No description provided for @thumbnailTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Choose an image of {megabytes} MB or less.'**
  String thumbnailTooLarge(int megabytes);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
