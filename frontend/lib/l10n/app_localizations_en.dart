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

  @override
  String get profileTitle => 'My Profile';

  @override
  String get favoritesSection => 'Favorites';

  @override
  String get savedSection => 'Saved for later';

  @override
  String get favoriteAction => 'Favorite';

  @override
  String get saveAction => 'Save';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get nameLabel => 'Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get nameOrEmailRequired => 'Name or email is required';

  @override
  String get guestName => 'Guest';

  @override
  String get newNewsTitle => 'New Article';

  @override
  String get editNewsTitle => 'Edit Article';

  @override
  String get formTitleLabel => 'Title';

  @override
  String get formSectionLabel => 'Section';

  @override
  String get formImagesLabel => 'Images';

  @override
  String get formBodyLabel => 'Content';

  @override
  String get formTitleHint => 'Write the article title...';

  @override
  String get formBodyHint => 'Write the article content here...';

  @override
  String formImageHintCreate(int max) {
    return 'Add up to $max photos';
  }

  @override
  String formImageHintEdit(int count, int max) {
    return '$count of $max photos';
  }

  @override
  String get publishButton => 'Publish Article';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesBody =>
      'You have unsaved changes. Do you want to discard them?';

  @override
  String get discardAction => 'Discard';

  @override
  String get deleteNewsTitle => 'Delete article?';

  @override
  String get deleteNewsBody => 'This action cannot be undone.';

  @override
  String get deleteAction => 'Delete';

  @override
  String get imageSourceCamera => 'Camera';

  @override
  String get imageSourceGallery => 'Gallery';

  @override
  String get genericError => 'An error occurred';

  @override
  String get errorNetwork =>
      'No internet connection. Please check your network.';

  @override
  String get errorServer => 'Server error. Please try again later.';

  @override
  String get errorStorage => 'Failed to upload images. Please try again.';

  @override
  String get errorNotFound => 'The article was not found.';
}
