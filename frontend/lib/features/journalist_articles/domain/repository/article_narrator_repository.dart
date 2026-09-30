import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../entities/article_narration.dart';
import '../entities/article_narration_progress.dart';

/// Reads articles aloud with the device's text-to-speech engine.
abstract class ArticleNarratorRepository {
  /// Reads [narration] sentence by sentence, emitting the progress as each sentence starts.
  /// Ends when the whole narration has been read or [stopReading] is called, and after a
  /// [DataFailed] when the device cannot speak.
  Stream<DataState<ArticleNarrationProgressEntity>> read(ArticleNarrationEntity narration);

  Future<DataState<void>> stopReading();
}
