// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Daily News';

  @override
  String get noArticlesYet => 'No articles yet. Be the first to publish!';

  @override
  String get articleSavedSuccessfully => 'Article saved successfully.';

  @override
  String get savedArticles => 'Saved Articles';

  @override
  String get noSavedArticles => 'No saved articles';

  @override
  String get writeTitleHint => 'Write your title here...';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get titleMaxLength => 'Title must be under 200 characters';

  @override
  String get attachImage => 'Attach Image';

  @override
  String get briefDescriptionHint => 'Brief description...';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get descriptionMaxLength => 'Description must be under 500 characters';

  @override
  String get addArticleHint => 'Add article here...';

  @override
  String get contentRequired => 'Article content is required';

  @override
  String get articlePublishedSuccessfully => 'Article published successfully!';

  @override
  String get failedToPublishArticle => 'Failed to publish article';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get commentsHeader => 'Comments';

  @override
  String get addCommentHint => 'Add a comment...';

  @override
  String get noCommentsYet => 'No comments yet. Be the first!';

  @override
  String get failedToLoadComments => 'Failed to load comments';

  @override
  String get unknownAuthor => 'Unknown';

  @override
  String get publishArticle => 'Publish Article';

  @override
  String get myArticles => 'My Articles';

  @override
  String get filterAll => 'All';

  @override
  String get filterDrafts => 'Drafts';

  @override
  String get filterPublished => 'Published';

  @override
  String get filterArchived => 'Archived';

  @override
  String get editDraft => 'Edit Draft';

  @override
  String get newArticle => 'New Article';

  @override
  String get editArticle => 'Edit Article';

  @override
  String get updateArticle => 'Update Article';

  @override
  String get deleteArticle => 'Delete Article';

  @override
  String get deleteArticleConfirmation =>
      'Are you sure you want to delete this article? This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get articleDeletedSuccessfully => 'Article deleted successfully.';

  @override
  String get failedToDeleteArticle => 'Failed to delete article';

  @override
  String get noUserArticles => 'You haven\'t written any articles yet.';

  @override
  String get articleUpdatedSuccessfully => 'Article updated successfully!';

  @override
  String get failedToUpdateArticle => 'Failed to update article';

  @override
  String get saveDraft => 'Save Draft';

  @override
  String get preview => 'Preview';

  @override
  String get saved => 'Saved';

  @override
  String get justSaved => 'Just saved';

  @override
  String savedTimeAgo(String time) {
    return 'Saved $time ago';
  }

  @override
  String get edit => 'Edit';

  @override
  String get saveDraftTooltip => 'Save draft';

  @override
  String get draft => 'Draft';

  @override
  String get published => 'Published';

  @override
  String get archived => 'Archived';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search articles...';

  @override
  String get typeToSearch => 'Type to search articles';

  @override
  String get noArticlesFound => 'No articles found';

  @override
  String get searchFailed => 'Search failed';

  @override
  String get myDrafts => 'My Drafts';

  @override
  String get noDraftsYet => 'No drafts yet';

  @override
  String get draftsEmptySubtitle =>
      'Start writing and your drafts will appear here';

  @override
  String get failedToLoadDrafts => 'Failed to load drafts';

  @override
  String get deleteDraft => 'Delete Draft';

  @override
  String get deleteDraftConfirmation =>
      'Are you sure you want to delete this draft? This cannot be undone.';

  @override
  String get keepEditing => 'Keep Editing';

  @override
  String get publish => 'Publish';

  @override
  String get untitled => 'Untitled';

  @override
  String get noContentYet => 'No content yet.';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get commentActionFailed => 'Could not complete comment action';

  @override
  String get loadArticlesFailed => 'Could not load articles';

  @override
  String get tapToRetry => 'Tap to retry';

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String get writeAnArticle => 'Write an article';

  @override
  String get writeTheFirstArticle => 'Write the first article';

  @override
  String get noArticlesTitle => 'No articles yet';

  @override
  String get noArticlesSubtitle =>
      'Your stories will appear here. Start writing something remarkable.';

  @override
  String get noDraftsTitle => 'No drafts';

  @override
  String get noDraftsSubtitle =>
      'Articles you\'re working on will be saved here automatically.';

  @override
  String get noPublishedTitle => 'Nothing published yet';

  @override
  String get noPublishedSubtitle =>
      'Share your work — publish an article to reach your readers.';

  @override
  String get noArchivedTitle => 'No archived articles';

  @override
  String get noArchivedSubtitle =>
      'Articles you archive will be stored here for reference.';

  @override
  String get noSavedTitle => 'No saved articles';

  @override
  String get noSavedSubtitle =>
      'Bookmark articles you\'d like to read later — they\'ll appear here.';

  @override
  String get undo => 'Undo';

  @override
  String get articleRemoved => 'Article removed';

  @override
  String get draftDeleted => 'Draft deleted';

  @override
  String get searchPrompt => 'Search for articles';

  @override
  String get searchPromptSubtitle => 'Find articles by title or description';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get tryDifferentKeywords =>
      'Try different keywords or check your spelling';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get couldNotLoadArticles =>
      'We couldn\'t load the articles. Check your connection and try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get appName => 'Symmetry';

  @override
  String get tabFeed => 'Feed';

  @override
  String get tabSearch => 'Search';

  @override
  String get tabSaved => 'Saved';

  @override
  String get tabProfile => 'Profile';

  @override
  String get sectionLatest => 'LATEST';

  @override
  String get signOut => 'Sign out';

  @override
  String readingTime(int minutes) {
    return '$minutes min read';
  }
}
