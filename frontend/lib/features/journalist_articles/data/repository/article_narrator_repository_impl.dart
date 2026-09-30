import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../domain/entities/article_narration.dart';
import '../../domain/entities/article_narration_progress.dart';
import '../../domain/repository/article_narrator_repository.dart';
import '../data_sources/local/text_to_speech_data_source.dart';

class ArticleNarratorRepositoryImpl implements ArticleNarratorRepository {
  final TextToSpeechDataSource _textToSpeechDataSource;

  ArticleNarratorRepositoryImpl(this._textToSpeechDataSource);

  @override
  Stream<DataState<ArticleNarrationProgressEntity>> read(ArticleNarrationEntity narration) async* {
    try {
      await for (final sentenceIndex in _textToSpeechDataSource.speak(narration)) {
        yield DataSuccess(ArticleNarrationProgressEntity(narration: narration, sentenceIndex: sentenceIndex));
      }
    } on Exception catch (error) {
      yield DataFailed(error);
    }
  }

  @override
  Future<DataState<void>> stopReading() async {
    try {
      await _textToSpeechDataSource.stop();
      return const DataSuccess(null);
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }
}
