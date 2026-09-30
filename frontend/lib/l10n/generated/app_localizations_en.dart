import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get topNewsTab => 'Top news';

  @override
  String get communityTab => 'Community';

  @override
  String get publishAnArticle => 'Publish an article';

  @override
  String get savedArticles => 'Saved articles';

  @override
  String get savedArticlesTitle => 'Saved Articles';

  @override
  String get noSavedArticles => 'NO SAVED ARTICLES';

  @override
  String get tryAgain => 'Try again';

  @override
  String get back => 'Back';

  @override
  String get articlePublished => 'Your article has been published.';

  @override
  String get articleSaved => 'Article saved successfully.';

  @override
  String get articlesCouldNotLoad => 'The articles could not be loaded.';

  @override
  String get noArticlesYet => 'No articles yet. Be the first journalist to publish one!';

  @override
  String get writeAnArticle => 'Write an article';

  @override
  String readingTime(int minutes) {
    return '$minutes min read';
  }

  @override
  String get listenToArticle => 'Listen to this article';

  @override
  String get stopReading => 'Stop reading';

  @override
  String get readingProgress => 'Reading progress';

  @override
  String get cannotReadAloud => 'This device cannot read aloud. Check the text-to-speech settings of your phone.';

  @override
  String get publishArticle => 'Publish Article';

  @override
  String get publishing => 'Publishing…';

  @override
  String get titleLabel => 'Title';

  @override
  String get titleHint => 'Write your title here…';

  @override
  String get authorLabel => 'Written by';

  @override
  String get authorHint => 'Your name';

  @override
  String get contentHint => 'Add article here… Use the toolbar for **bold** text and ## subtitles.';

  @override
  String get write => 'Write';

  @override
  String get preview => 'Preview';

  @override
  String get nothingToPreview => '*Nothing to preview yet.*';

  @override
  String get bold => 'Bold';

  @override
  String get italic => 'Italic';

  @override
  String get subtitle => 'Subtitle';

  @override
  String get bulletedList => 'Bulleted list';

  @override
  String writingStats(int words, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      words,
      locale: localeName,
      other: '$words words',
      one: '1 word',
    );
    return '$_temp0 · $minutes min read';
  }

  @override
  String charactersUsed(int length, int maxLength) {
    return '$length of $maxLength characters used';
  }

  @override
  String get attachImage => 'Attach Image';

  @override
  String get changeImage => 'Change image';

  @override
  String get articleImageHint => 'Article image. Double tap to choose another one.';

  @override
  String get draftRestored => 'We restored the article you left unfinished.';

  @override
  String get startOver => 'Start over';

  @override
  String get saveDraftQuestion => 'Save this article as a draft?';

  @override
  String get saveDraftExplanation => 'You can finish it the next time you tap +.';

  @override
  String get keepWriting => 'Keep writing';

  @override
  String get discard => 'Discard';

  @override
  String get saveDraft => 'Save draft';

  @override
  String get publishFailed => 'Your article could not be published. Check your connection and try again.';

  @override
  String get galleryUnavailable => 'The gallery could not be opened. Check the app permissions and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get titleEmpty => 'Add a title for your article.';

  @override
  String titleTooLong(int maxLength) {
    final intl.NumberFormat maxLengthNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String maxLengthString = maxLengthNumberFormat.format(maxLength);

    return 'The title can have up to $maxLengthString characters.';
  }

  @override
  String get authorEmpty => 'Sign the article with your name.';

  @override
  String authorTooLong(int maxLength) {
    final intl.NumberFormat maxLengthNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String maxLengthString = maxLengthNumberFormat.format(maxLength);

    return 'Your name can have up to $maxLengthString characters.';
  }

  @override
  String get contentEmpty => 'Write your article before publishing it.';

  @override
  String contentTooLong(int maxLength) {
    final intl.NumberFormat maxLengthNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String maxLengthString = maxLengthNumberFormat.format(maxLength);

    return 'The article can have up to $maxLengthString characters.';
  }

  @override
  String get thumbnailMissing => 'Attach an image to illustrate your article.';

  @override
  String get thumbnailUnsupportedFormat => 'Choose a JPG, PNG or WebP image.';

  @override
  String thumbnailTooLarge(int megabytes) {
    return 'Choose an image of $megabytes MB or less.';
  }
}
