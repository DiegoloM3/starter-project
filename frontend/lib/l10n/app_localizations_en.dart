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

  @override
  String get myNewsTab => 'My News';

  @override
  String get worldNewsTab => 'World News';

  @override
  String get newsLoadError => 'Failed to load news';

  @override
  String get retryAction => 'Retry';

  @override
  String get noNewsAvailable => 'No news available';

  @override
  String get profileButtonLabel => 'Profile';

  @override
  String get addNewsButtonLabel => 'Add news';

  @override
  String get searchNewsHint => 'Search news...';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get searchButtonLabel => 'Search';

  @override
  String get sectionAll => 'All';

  @override
  String get sectionPolitics => 'Politics';

  @override
  String get sectionWeather => 'Weather';

  @override
  String get sectionSports => 'Sports';

  @override
  String get sectionArts => 'Arts';

  @override
  String get sectionCrime => 'Crime';
}
