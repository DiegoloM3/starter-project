import '../../../domain/entities/article.dart';

class ArticleDetailContent {
  final String text;
  final bool isExcerpt;

  const ArticleDetailContent({required this.text, required this.isExcerpt});
}

ArticleDetailContent composeArticleDetailContent(ArticleEntity article) {
  final description = _cleanNewsApiText(article.description);
  final content = _cleanNewsApiText(article.content);

  if (description.value.isEmpty && content.value.isEmpty) {
    return const ArticleDetailContent(
      text: 'No article excerpt is available.',
      isExcerpt: true,
    );
  }
  if (content.value.isEmpty) {
    return ArticleDetailContent(
      text: description.value,
      isExcerpt: true,
    );
  }
  if (description.value.isEmpty) {
    return ArticleDetailContent(
      text: content.value,
      isExcerpt: content.wasTruncated,
    );
  }

  if (_isNearDuplicate(
    description.value,
    content.value,
    allowParaphrase: description.wasTruncated || content.wasTruncated,
  )) {
    final cleanDescription = _stripWireDateline(description.value).trim();
    final cleanContent = _stripWireDateline(content.value).trim();
    final selected = cleanContent.length >= cleanDescription.length
        ? cleanContent
        : cleanDescription;
    return ArticleDetailContent(
      text: selected,
      isExcerpt: description.wasTruncated || content.wasTruncated,
    );
  }

  return ArticleDetailContent(
    text: '${description.value}\n\n${content.value}',
    isExcerpt: description.wasTruncated || content.wasTruncated,
  );
}

class _CleanText {
  final String value;
  final bool wasTruncated;

  const _CleanText(this.value, this.wasTruncated);
}

_CleanText _cleanNewsApiText(String? value) {
  var text = value?.trim() ?? '';
  if (text.isEmpty) return const _CleanText('', false);

  final marker = RegExp(r'\s*\[\+\d+\s+chars?\]\s*$', caseSensitive: false);
  final wasTruncated = marker.hasMatch(text);
  if (wasTruncated) {
    text = text.replaceFirst(marker, '').trimRight();
    text = text.replaceFirst(RegExp(r'(?:\.\.\.|…)\s*$'), '').trimRight();
  }
  return _CleanText(text, wasTruncated);
}

bool _isNearDuplicate(
  String first,
  String second, {
  required bool allowParaphrase,
}) {
  final normalizedFirst = _normalize(first);
  final normalizedSecond = _normalize(second);
  if (normalizedFirst == normalizedSecond) return true;

  final shorter = normalizedFirst.length <= normalizedSecond.length
      ? normalizedFirst
      : normalizedSecond;
  final longer =
      shorter == normalizedFirst ? normalizedSecond : normalizedFirst;
  if (shorter.length >= 32 && longer.contains(shorter)) {
    return shorter.length / longer.length >= 0.72;
  }
  if (!allowParaphrase) return false;

  final shorterWords = shorter.split(' ');
  final longerWords = longer.split(' ');
  if (shorterWords.length < 8) return false;

  final shorterWordSet = shorterWords.toSet();
  final longerWordSet = longerWords.toSet();
  final commonWords = shorterWordSet.intersection(longerWordSet).length;
  final wordOverlap = commonWords / shorterWordSet.length;
  final commonOpeningWords = _commonOpeningWords(shorterWords, longerWords);
  return commonOpeningWords >= 5 && wordOverlap >= 0.72;
}

String _normalize(String value) => _stripWireDateline(value)
    .toLowerCase()
    .replaceAll(RegExp(r"['’]"), '')
    .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
    .trim();

int _commonOpeningWords(List<String> first, List<String> second) {
  final limit = first.length < second.length ? first.length : second.length;
  var common = 0;
  while (common < limit && first[common] == second[common]) {
    common++;
  }
  return common;
}

String _stripWireDateline(String value) => value.replaceFirst(
      RegExp(
        r"^\s*[A-Za-z][A-Za-z .,‘’–—'-]{2,50}\s+\((?:AP|Reuters|AFP)\)\s*[-:–—]?\s*",
        caseSensitive: false,
      ),
      '',
    );
