// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get landingTagline => 'WELLNESS · KNOWLEDGE · COMMUNITY';

  @override
  String get landingHeroLine1 => 'One tip a day.';

  @override
  String get landingHeroLine2 => 'A better life.';

  @override
  String get landingTermsPrefix => 'By continuing, you agree to the ';

  @override
  String get landingTermsOfService => 'Terms of Service';

  @override
  String get landingTermsMiddle =>
      ' of TortuTip and confirm you have read our ';

  @override
  String get landingPrivacyPolicy => 'Privacy Policy';

  @override
  String get loginTitle => 'Welcome to TortuTip';

  @override
  String get loginSubtitle => 'We protect your privacy. Google only.';

  @override
  String get onboardingCategoriesTitle => 'Personalize your feed';

  @override
  String get onboardingCategoriesSubtitle =>
      'Select the topics that interest you most to adapt your experience 1% every day.';

  @override
  String get onboardingNext => 'Next →';

  @override
  String get onboardingRoleWriter => 'Share tips';

  @override
  String get onboardingRoleReader => 'Read tips';

  @override
  String get onboardingDetailsTitle => 'Tell us a little more';

  @override
  String get onboardingDetailsGender => 'Gender';

  @override
  String get onboardingDetailsAgeRange => 'Age range';

  @override
  String get onboardingGenderFemale => 'Female';

  @override
  String get onboardingGenderMale => 'Male';

  @override
  String get onboardingGenderOther => 'Other';

  @override
  String get onboardingGenderPreferNotToSay => 'Prefer not to say';

  @override
  String get onboardingFinish => 'Finish →';

  @override
  String get feedTitle => 'TortuTip';

  @override
  String get feedNoArticles => 'No articles available';

  @override
  String get feedStartOver => 'Start over';

  @override
  String get feedReadAll => 'You\'ve read everything!';

  @override
  String get feedReadAllSubtitle => 'Start over with a random order';

  @override
  String get articleDetailTitle => 'Detail';

  @override
  String get articleDetailRetry => 'Retry';

  @override
  String get createArticleDiscardTitle => 'Discard article?';

  @override
  String get createArticleDiscardContent =>
      'Your article will be lost if you leave now.';

  @override
  String get createArticleKeepEditing => 'Keep editing';

  @override
  String get createArticleDiscard => 'Discard';

  @override
  String get createArticleCameraOption => 'Camera';

  @override
  String get createArticleLibraryOption => 'Photo library';

  @override
  String get createArticleNotAuthError => 'Error: user not authenticated';

  @override
  String get createArticlePreview => 'Preview';

  @override
  String get createArticlePublish => 'Publish';

  @override
  String get createArticleUpdate => 'Update';

  @override
  String get createArticleChooseCategory => 'Choose Category';

  @override
  String get createArticleTitleHint => 'Write your title...';

  @override
  String get createArticleBodyHint =>
      'Start your journey here... share your wisdom with the world.';

  @override
  String get categoryListTitle => 'Category';

  @override
  String get categoryListEmpty => 'No articles';

  @override
  String get categoryListEmptySubtitle =>
      'No articles published in this category yet.';

  @override
  String get categoryListLoadMore => 'Load more';

  @override
  String get bookmarksTitle => 'My Bookmarks';

  @override
  String get bookmarksEmpty => 'No bookmarks yet';

  @override
  String get bookmarksEmptySubtitle =>
      'Save articles you\'re interested in to read later.';

  @override
  String get bookmarksLoadMore => 'Load more';

  @override
  String get bookmarksRemoved => 'Removed from bookmarks';

  @override
  String get bookmarksUndo => 'Undo';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get profileMyTips => 'My Tips';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get editProfileCamera => 'Camera';

  @override
  String get editProfileGallery => 'Gallery';

  @override
  String get editProfileSignOutTitle => 'Sign out';

  @override
  String get editProfileSignOutContent => 'Are you sure you want to sign out?';

  @override
  String get editProfileSignOutConfirm => 'Sign out';

  @override
  String get editProfileDeleteAccountTitle => 'Delete account';

  @override
  String get editProfileDeleteAccountConfirm => 'Delete';

  @override
  String get editProfileCancel => 'Cancel';

  @override
  String get editProfileNameHint => 'Your name';

  @override
  String get editProfileBioHint => 'Tell us about yourself';

  @override
  String get editProfileSaveChanges => 'Save Changes';

  @override
  String get articleMenuView => 'View';

  @override
  String get articleMenuEdit => 'Edit';

  @override
  String get articleMenuDelete => 'Delete';

  @override
  String get articleDeleteTitle => 'Delete article';

  @override
  String get articleDeleteContent =>
      'Are you sure you want to delete this article? This action cannot be undone.';

  @override
  String get articleDeleteCancel => 'Cancel';

  @override
  String get searchRecentSearches => 'Recent searches';

  @override
  String get searchStartSearching => 'Start searching...';

  @override
  String get searchNoArticles => 'No articles found';

  @override
  String get searchNoCategories => 'No categories found';

  @override
  String get searchCancel => 'Cancel';

  @override
  String get searchBarHint => 'Search articles, categories...';

  @override
  String get feedCardUnknownAuthor => 'Unknown author';

  @override
  String feedCardReadTime(int minutes) {
    return '$minutes min read';
  }

  @override
  String get feedCardReadMore => 'Read more →';

  @override
  String get feedForYou => 'For you';

  @override
  String get articleSaved => 'Saved';

  @override
  String get articleSave => 'Save';

  @override
  String get coverVerticalLabel => 'VERTICAL COVER\n(FEED)';

  @override
  String get coverHorizontalLabel => 'HORIZONTAL COVER\n(ARTICLE)';

  @override
  String get errorGeneric => 'Something went wrong. Try again';

  @override
  String get errorNoConnection => 'No connection. Try again';

  @override
  String get discard => 'Discard';

  @override
  String get bookmarksExploreAction => 'Explore articles';

  @override
  String get bookmarksSectionLabel => '— SAVED';

  @override
  String get bookmarksSectionTitle => 'My Bookmarks';

  @override
  String get bookmarksSectionSubtitle => 'Articles you saved to read later.';

  @override
  String get bookmarksRetry => 'Retry';

  @override
  String get feedRetry => 'Retry';

  @override
  String get exploreKaiaTitle => 'Kaia, your turtle 🐢';

  @override
  String get exploreCategoriesTitle => 'Categories';

  @override
  String get exploreSearchHint => 'Search articles...';

  @override
  String exploreStreakDays(int days) {
    return 'Day $days streak';
  }

  @override
  String get exploreStreakMotivation => '🔥 Keep it up!';

  @override
  String get searchEmptyTitle => 'No results found';

  @override
  String get searchEmptySubtitle =>
      'Try different keywords or explore a category';

  @override
  String get searchEmptyExploreLabel => 'Explore categories';

  @override
  String get articleDetailRelated => 'More like this';

  @override
  String get categoryListSectionLabel => '— CATEGORY';

  @override
  String searchTabArticles(int count) {
    return 'Articles ($count)';
  }

  @override
  String searchTabCategories(int count) {
    return 'Categories ($count)';
  }

  @override
  String get searchFilterAll => 'All';

  @override
  String get tortuFeedTitle => 'Feed Tortu';

  @override
  String get tortuFeedComeBackTomorrow =>
      'Come back tomorrow to keep feeding Tortu 🐢';

  @override
  String get tortuFeedSlideHint => 'Slide →';

  @override
  String get tortuFeedCompleted => 'Tip learned!';

  @override
  String get tortuFeedHappy => 'Tortu is happy +1%';

  @override
  String get createArticlePublishedSuccess => 'Article published successfully!';
}
