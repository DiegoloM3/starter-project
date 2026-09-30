import 'package:equatable/equatable.dart';

import 'markdown_text.dart';
import 'published_article.dart';

enum NarrationPartKind { title, byline, heading, bulletedItem, numberedItem, paragraph }

/// A block of the article (its title, a heading, a paragraph…) split into the sentences read aloud.
class NarrationPart extends Equatable {
  final NarrationPartKind kind;
  final List<String> sentences;

  const NarrationPart(this.kind, this.sentences);

  @override
  List<Object?> get props => [kind, sentences];
}

/// What the device reads aloud for an article: title, byline and content as plain sentences,
/// in the article's language.
class ArticleNarrationEntity extends Equatable {
  static const String english = 'en-US';
  static const String spanish = 'es-ES';

  final List<NarrationPart> parts;

  /// BCP 47 tag of the voice to use.
  final String languageTag;

  const ArticleNarrationEntity({required this.parts, required this.languageTag});

  factory ArticleNarrationEntity.of(PublishedArticleEntity article) {
    final contentLines = markdownToPlainLines(article.content);
    final languageTag = _guessLanguageTag([article.title, ...contentLines.map((line) => line.text)].join(' '));
    final byline = '${languageTag == spanish ? 'Escrito por' : 'Written by'} ${article.author}';
    return ArticleNarrationEntity(
      parts: [
        NarrationPart(NarrationPartKind.title, [article.title]),
        NarrationPart(NarrationPartKind.byline, [byline]),
        ...contentLines.map(_partOf),
      ],
      languageTag: languageTag,
    );
  }

  /// Everything read aloud, in order. The voice pauses after each sentence.
  List<String> get sentences => [for (final part in parts) ...part.sentences];

  @override
  List<Object?> get props => [parts, languageTag];
}

final _sentenceBoundary = RegExp(r'(?<=[.!?…])\s+');

NarrationPart _partOf(PlainTextLine line) {
  final kind = switch (line.kind) {
    PlainLineKind.heading => NarrationPartKind.heading,
    PlainLineKind.bulletedItem => NarrationPartKind.bulletedItem,
    PlainLineKind.numberedItem => NarrationPartKind.numberedItem,
    PlainLineKind.paragraph => NarrationPartKind.paragraph,
  };
  return NarrationPart(kind, line.text.split(_sentenceBoundary));
}

const _spanishWords = {
  'el', 'la', 'los', 'las', 'de', 'del', 'que', 'y', 'en', 'un', 'una', 'es', 'por', 'para', 'con', 'su', 'lo', 'al', 'se',
};
const _englishWords = {
  'the', 'and', 'of', 'to', 'is', 'in', 'that', 'for', 'with', 'it', 'on', 'by', 'an', 'this', 'are', 'what', 'from',
};
final _nonLetters = RegExp(r'[^a-záéíóúüñ]+');

/// English or Spanish, whichever has more of its most common words. English when tied.
String _guessLanguageTag(String text) {
  final words = text.toLowerCase().split(_nonLetters);
  final spanishCount = words.where(_spanishWords.contains).length;
  final englishCount = words.where(_englishWords.contains).length;
  return spanishCount > englishCount ? ArticleNarrationEntity.spanish : ArticleNarrationEntity.english;
}
