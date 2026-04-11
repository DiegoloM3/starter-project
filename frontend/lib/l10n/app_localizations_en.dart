// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dailyNewsTitle => 'Daily News';

  @override
  String get articleTitle => 'Article';

  @override
  String get savedArticlesTitle => 'Saved Articles';

  @override
  String get noSavedArticles => 'No saved articles';

  @override
  String get articleSavedSuccess => 'Article saved successfully.';

  @override
  String get uploadImage => 'Upload image';
}
