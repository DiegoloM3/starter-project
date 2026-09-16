import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/speech_repository.dart';

class ReadAloudParams extends Equatable {
  final String text;

  /// 1.0 is the device's normal pace.
  final double rate;

  const ReadAloudParams({required this.text, this.rate = 1.0});

  @override
  List<Object?> get props => [text, rate];
}

/// Reads a text aloud. Blank text is refused before touching the voice.
class ReadAloudUseCase implements UseCase<DataState<void>, ReadAloudParams> {
  final SpeechRepository _speech;

  const ReadAloudUseCase(this._speech);

  @override
  Future<DataState<void>> call(ReadAloudParams params) {
    if (params.text.trim().isEmpty) {
      return Future.value(const DataFailed(Failure.validation('There is nothing to read.')));
    }
    return _speech.speak(params.text.trim(), rate: params.rate);
  }
}
