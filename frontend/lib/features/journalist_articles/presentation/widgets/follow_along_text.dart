import 'package:flutter/material.dart';

import '../../domain/entities/article_narration.dart';
import '../../domain/entities/article_narration_progress.dart';

/// Highlighter yellow behind the sentence being read aloud.
const Color readAloudHighlightColor = Color(0xFFFFE58F);

/// Dark text on the yellow highlight, readable in the light and the dark theme.
const TextStyle readAloudHighlightStyle = TextStyle(backgroundColor: readAloudHighlightColor, color: Colors.black87);

/// The article content while it is read aloud: the sentence being read is highlighted and the
/// page scrolls to keep it in view, so readers can follow along.
class FollowAlongText extends StatefulWidget {
  final ArticleNarrationProgressEntity progress;

  const FollowAlongText({super.key, required this.progress});

  @override
  State<FollowAlongText> createState() => _FollowAlongTextState();
}

class _FollowAlongTextState extends State<FollowAlongText> {
  static const Set<NarrationPartKind> _contentKinds = {
    NarrationPartKind.heading,
    NarrationPartKind.bulletedItem,
    NarrationPartKind.numberedItem,
    NarrationPartKind.paragraph,
  };

  late final List<GlobalKey> _partKeys = List.generate(_parts.length, (_) => GlobalKey());

  /// Index in the narration's sentences of the first sentence of each part.
  late final List<int> _firstSentenceIndexes = _firstSentenceIndexesOf(_parts);

  /// "•", "1.", "2."… for list items, `null` for the other parts.
  late final List<String?> _listMarkers = _listMarkersOf(_parts);

  List<NarrationPart> get _parts => widget.progress.narration.parts;

  @override
  void initState() {
    super.initState();
    _scrollToCurrentPartAfterLayout();
  }

  @override
  void didUpdateWidget(FollowAlongText oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasPartChanged = _partIndexOf(oldWidget.progress.sentenceIndex) != _currentPartIndex;
    if (hasPartChanged) _scrollToCurrentPartAfterLayout();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < _parts.length; index++)
          if (_contentKinds.contains(_parts[index].kind)) _buildPart(context, index),
      ],
    );
  }

  Widget _buildPart(BuildContext context, int partIndex) {
    final style = _styleOf(context, _parts[partIndex].kind);
    final marker = _listMarkers[partIndex];
    final text = Text.rich(_sentencesOf(partIndex), style: style);
    return Padding(
      key: _partKeys[partIndex],
      padding: const EdgeInsets.only(bottom: 14),
      child: marker == null ? text : _asListItem(Text(marker, style: style), text),
    );
  }

  /// The sentences of a part, with the one being read highlighted.
  TextSpan _sentencesOf(int partIndex) {
    final sentences = _parts[partIndex].sentences;
    final currentSentence = widget.progress.sentenceIndex - _firstSentenceIndexes[partIndex];
    return TextSpan(children: [
      for (var index = 0; index < sentences.length; index++) ...[
        if (index > 0) const TextSpan(text: ' '),
        _sentenceSpan(sentences[index], isCurrent: index == currentSentence),
      ],
    ]);
  }

  /// The marker in its own column, so wrapped lines stay aligned with the text, as in Markdown.
  Widget _asListItem(Widget marker, Widget text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [SizedBox(width: 28, child: marker), Expanded(child: text)],
      ),
    );
  }

  TextSpan _sentenceSpan(String sentence, {required bool isCurrent}) {
    return TextSpan(
      text: sentence,
      style: isCurrent ? readAloudHighlightStyle : null,
    );
  }

  TextStyle? _styleOf(BuildContext context, NarrationPartKind kind) {
    final textTheme = Theme.of(context).textTheme;
    if (kind == NarrationPartKind.heading) return textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);
    return textTheme.bodyLarge?.copyWith(fontSize: 17, height: 1.6);
  }

  int get _currentPartIndex => _partIndexOf(widget.progress.sentenceIndex);

  int _partIndexOf(int sentenceIndex) => _firstSentenceIndexes.lastIndexWhere((first) => first <= sentenceIndex);

  void _scrollToCurrentPartAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final partContext = _partKeys[_currentPartIndex].currentContext;
      if (partContext == null) return;
      Scrollable.ensureVisible(
        partContext,
        alignment: 0.2,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }
}

List<int> _firstSentenceIndexesOf(List<NarrationPart> parts) {
  final indexes = <int>[];
  var next = 0;
  for (final part in parts) {
    indexes.add(next);
    next += part.sentences.length;
  }
  return indexes;
}

List<String?> _listMarkersOf(List<NarrationPart> parts) {
  final markers = <String?>[];
  var number = 0;
  for (final part in parts) {
    number = part.kind == NarrationPartKind.numberedItem ? number + 1 : 0;
    markers.add(switch (part.kind) {
      NarrationPartKind.bulletedItem => '•',
      NarrationPartKind.numberedItem => '$number.',
      _ => null,
    });
  }
  return markers;
}
