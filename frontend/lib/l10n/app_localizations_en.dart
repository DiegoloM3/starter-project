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
}
