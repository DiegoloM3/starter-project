import 'package:flutter_tts/flutter_tts.dart';

import '../../../domain/entities/article_narration.dart';

/// The device's text-to-speech engine (offline, no API key).
class TextToSpeechDataSource {
  // Android rejects longer texts (TextToSpeech.getMaxSpeechInputLength() is 4000).
  static const int maxSpeechLength = 3900;
  static const int _speakSucceeded = 1;
  static const double _comfortableSpeechRate = 0.45;

  final FlutterTts _tts;
  bool _isStopRequested = false;

  TextToSpeechDataSource(this._tts);

  /// Reads the sentences of [narration] one after another, emitting the index of each sentence
  /// when it starts. Speaking one sentence at a time tells exactly which one is being read on
  /// every platform. Ends when the narration ends or [stop] is called.
  /// Throws an [Exception] when the device cannot speak.
  Stream<int> speak(ArticleNarrationEntity narration) async* {
    _isStopRequested = false;
    await _prepareVoice(narration.languageTag);
    final sentences = narration.sentences;
    for (var index = 0; index < sentences.length; index++) {
      if (_isStopRequested) return;
      yield index;
      await _speakSentence(sentences[index]);
    }
  }

  Future<void> stop() async {
    _isStopRequested = true;
    await _tts.stop();
  }

  /// Splits a [sentence] longer than [maxSpeechLength] characters into parts the engine accepts.
  static List<String> splitIntoSpeakableParts(String sentence) {
    return [
      for (var start = 0; start < sentence.length; start += maxSpeechLength)
        sentence.substring(start, (start + maxSpeechLength).clamp(0, sentence.length)),
    ];
  }

  Future<void> _prepareVoice(String languageTag) async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setSpeechRate(_comfortableSpeechRate);
    if (await _tts.isLanguageAvailable(languageTag) == true) {
      await _tts.setLanguage(languageTag);
    }
  }

  Future<void> _speakSentence(String sentence) async {
    for (final part in splitIntoSpeakableParts(sentence)) {
      if (_isStopRequested) return;
      final result = await _tts.speak(part);
      if (result != _speakSucceeded && !_isStopRequested) {
        throw Exception('The device could not read the article aloud');
      }
    }
  }
}
