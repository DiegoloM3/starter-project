// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navNews => 'NEWS';

  @override
  String get navCommunity => 'COMMUNITY';

  @override
  String get navSaved => 'SAVED';

  @override
  String get navAccount => 'ACCOUNT';

  @override
  String get actionWrite => 'Write';

  @override
  String get dailyNewsTitle => 'Daily News';

  @override
  String get newsLoadFailed => 'We could not load the news.';

  @override
  String get newsEmptyTitle => 'No news right now';

  @override
  String get newsEmptyMessage =>
      'Nothing in this section at the moment. Try another one, or check back in a little while.';

  @override
  String get readMore => 'Read More';

  @override
  String get tryAgain => 'Try again';

  @override
  String get checkConnection => 'Check your connection and try again.';

  @override
  String get categoryGeneral => 'General';

  @override
  String get categoryBusiness => 'Business';

  @override
  String get categoryTechnology => 'Technology';

  @override
  String get categoryScience => 'Science';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get savedTitle => 'Saved Articles';

  @override
  String get savedEmptyTitle => 'Nothing saved yet';

  @override
  String get savedEmptyMessage =>
      'Open an article and tap Save to keep it here for later.';

  @override
  String get removedFromSaved => 'Removed from saved.';

  @override
  String get undo => 'Undo';

  @override
  String get removeFromSaved => 'Remove from saved';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get savedConfirmation => 'Saved. Find it in the Saved tab.';

  @override
  String get articleUnavailable => 'This article is no longer available.';

  @override
  String get communityTitle => 'Community Articles';

  @override
  String get loadMoreArticles => 'Load more articles';

  @override
  String get communityLoadFailed => 'Could not load articles.';

  @override
  String get communityEmptyRecentTitle => 'Nothing new this week';

  @override
  String communityEmptyRecentMessage(int days) {
    return 'The community feed shows what was published in the last $days days. Be the first to write something.';
  }

  @override
  String get authorEmptyTitle => 'No articles yet';

  @override
  String get authorEmptyMessage =>
      'This journalist has not published anything yet.';

  @override
  String byAuthor(String author) {
    return 'By $author';
  }

  @override
  String viewsCount(String count) {
    return '$count views';
  }

  @override
  String moreFrom(String name) {
    return 'More from $name';
  }

  @override
  String get thisAuthor => 'this author';

  @override
  String get myArticlesTitle => 'My Articles';

  @override
  String get searchMyArticles => 'Search in my articles';

  @override
  String get filterAll => 'All';

  @override
  String get filterDrafts => 'Drafts';

  @override
  String get filterPublished => 'Published';

  @override
  String get badgeDraft => 'DRAFT';

  @override
  String get badgePublished => 'PUBLISHED';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get publish => 'Publish';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteArticleTitle => 'Delete article';

  @override
  String deleteArticleMessage(String title) {
    return '\"$title\" will be deleted permanently. This cannot be undone.';
  }

  @override
  String get myArticlesLoadFailed => 'Could not load your articles.';

  @override
  String get noMatchesTitle => 'Nothing matches';

  @override
  String get noMatchesMessage => 'Try another search, or a different filter.';

  @override
  String get myArticlesEmptyTitle => 'No articles yet';

  @override
  String get myArticlesEmptyMessage =>
      'Everything you write will show up here, drafts included.';

  @override
  String get writeFirstArticle => 'Write your first article';

  @override
  String publishedOn(String date) {
    return 'Published $date';
  }

  @override
  String savedOn(String date) {
    return 'Saved $date';
  }

  @override
  String get notSavedYet => 'Not saved yet';

  @override
  String get newArticle => 'New article';

  @override
  String get editArticle => 'Edit article';

  @override
  String get addCoverImage => 'Add cover image';

  @override
  String get recommendedSize => 'Recommended size: 1200 × 630 px';

  @override
  String get replace => 'Replace';

  @override
  String get remove => 'Remove';

  @override
  String get titleHint => 'Write your title here...';

  @override
  String get descriptionHint => 'Add a short description...';

  @override
  String get contentHint => 'Start writing your article...';

  @override
  String get articleSection => 'Article';

  @override
  String get preview => 'Preview';

  @override
  String get keepWriting => 'Keep writing';

  @override
  String get nothingToPreview => 'Nothing to preview yet.';

  @override
  String draftSavedAt(String time) {
    return 'Draft saved · $time';
  }

  @override
  String get saving => 'Saving...';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get unsavedTitle => 'Your changes are not saved';

  @override
  String get unsavedMessage =>
      'Leaving now loses what you have written since the last save.';

  @override
  String get discard => 'Discard';

  @override
  String get howToWrite => 'How to write an article';

  @override
  String get toolbarHeading => 'Heading';

  @override
  String get toolbarBold => 'Bold';

  @override
  String get toolbarItalic => 'Italic';

  @override
  String get toolbarList => 'List';

  @override
  String get toolbarQuote => 'Quote';

  @override
  String get whatYouType => 'What you type';

  @override
  String get whatReadersSee => 'What readers see';

  @override
  String tourStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get skip => 'Skip';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get gotIt => 'Got it';

  @override
  String get tourCoverTitle => 'Start with a cover';

  @override
  String get tourCoverBody =>
      'Pick a picture from your phone. A moving GIF works too, and it is the first thing a reader sees.';

  @override
  String get tourTitleTitle => 'Give it a title';

  @override
  String get tourTitleBody =>
      'One line that says what the article is about. You can save a draft with nothing but this.';

  @override
  String get tourFormatTitle => 'Format as you write';

  @override
  String get tourFormatBody =>
      'Select some words and press a button. You never have to remember the symbols — these write them for you.';

  @override
  String get tourPreviewTitle => 'See it as a reader will';

  @override
  String get tourPreviewBody =>
      'Preview shows the finished article. Switch back whenever you want to keep writing.';

  @override
  String get tourPublishTitle => 'Publish when it is ready';

  @override
  String get tourPublishBody =>
      'Publishing needs a title, a description, a cover and some writing. Until then, Save changes keeps it private.';

  @override
  String get articleLiveTitle => 'Your article is live';

  @override
  String get articleLiveMessage =>
      'Anyone can now read it in the Community feed.';

  @override
  String get viewArticle => 'View article';

  @override
  String get backToMyArticles => 'Back to my articles';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get forgotPassword => 'I forgot my password';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get repeatPassword => 'Repeat password';

  @override
  String get displayNameOptional => 'Name readers will see (optional)';

  @override
  String atLeastCharacters(int count) {
    return 'At least $count characters';
  }

  @override
  String get newHereCreateAccount => 'New here?  Create an account';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get resetRequested => 'Reset requested';

  @override
  String get resetInstructions =>
      'Enter the email you signed up with and we will send you a link to choose a new password.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get resetSentMessage =>
      'If that email has an account, a reset link is on its way. Open it to choose a new password, then come back and sign in.';

  @override
  String get resetSpamHint =>
      'Hint: Be sure to check your spam or promotions folder if it doesn\'t arrive in a few minutes.';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get accountInviteTitle => 'Write your own stories';

  @override
  String get accountInviteMessage =>
      'Reading is always free. An account only takes a moment, and it is what lets you publish.';

  @override
  String get myArticles => 'My articles';

  @override
  String get nameReadersSee => 'Name readers see';

  @override
  String get yourName => 'Your name';

  @override
  String get nameHelper =>
      'Shown as the author of everything you publish next.';

  @override
  String get signOut => 'Sign out';

  @override
  String statsSummary(String articles, String views) {
    return '$articles  ·  $views views';
  }

  @override
  String articleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String get errorEmailInUse =>
      'That email already has an account. Sign in instead.';

  @override
  String get errorInvalidCredentials =>
      'That email and password do not match an account.';

  @override
  String get errorNotSignedIn => 'Sign in to continue.';

  @override
  String get errorTooManyAttempts =>
      'Too many attempts. Try again in a few minutes.';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get errorEmailRequired => 'Enter your email.';

  @override
  String get errorEmailMalformed => 'That does not look like an email address.';

  @override
  String get errorPasswordRequired => 'Enter your password.';

  @override
  String errorPasswordTooShort(int count) {
    return 'Use at least $count characters.';
  }

  @override
  String get errorPasswordsDiffer => 'The two passwords are different.';

  @override
  String errorDisplayName(int count) {
    return 'Enter a name of up to $count characters.';
  }

  @override
  String get errorTitleRequired => 'The article needs a title.';

  @override
  String get errorTitleTooLong => 'The title is too long.';

  @override
  String get errorDescriptionRequired => 'Readers need a short description.';

  @override
  String get errorDescriptionTooLong => 'The description is too long.';

  @override
  String get errorContentRequired => 'The article has no content yet.';

  @override
  String get errorThumbnailRequired => 'Add a cover image before publishing.';

  @override
  String get errorAuthorRequired => 'The article has no author.';

  @override
  String get errorOwnerRequired => 'The article has no owner.';

  @override
  String get errorArticleNotFound => 'This article no longer exists.';

  @override
  String get errorArticleNotStored => 'Save the article before publishing it.';

  @override
  String get errorImageEmpty => 'The selected image is empty.';

  @override
  String get errorImageTooLarge => 'The image is larger than 5 MB.';

  @override
  String get errorImageFormat =>
      'Only jpg, png, webp and gif images are supported.';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get errorNoConnection =>
      'No internet connection. Check your connection and try again.';

  @override
  String get appName => 'Byline';

  @override
  String get appTagline => 'Read it. Write it.';

  @override
  String get signInSubtitle => 'Sign in to publish under your own name.';

  @override
  String get signUpSubtitle =>
      'An account is only needed to write. Reading is always free.';

  @override
  String get newsPreviewNotice =>
      'The News API only sends a preview of each article. The full story is at the source.';

  @override
  String get openAtSource => 'Read the full article at';

  @override
  String bylineUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your $count published articles now carry the new name.',
      one: 'Your published article now carries the new name.',
    );
    return '$_temp0';
  }
}
