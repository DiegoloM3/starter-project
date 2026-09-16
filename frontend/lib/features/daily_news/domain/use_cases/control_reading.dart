import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/speech_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/speech_repository.dart';

class PauseReadingUseCase implements UseCase<DataState<void>, NoParams> {
  final SpeechRepository _speech;

  const PauseReadingUseCase(this._speech);

  @override
  Future<DataState<void>> call(NoParams params) => _speech.pause();
}

class ResumeReadingUseCase implements UseCase<DataState<void>, NoParams> {
  final SpeechRepository _speech;

  const ResumeReadingUseCase(this._speech);

  @override
  Future<DataState<void>> call(NoParams params) => _speech.resume();
}

class StopReadingUseCase implements UseCase<DataState<void>, NoParams> {
  final SpeechRepository _speech;

  const StopReadingUseCase(this._speech);

  @override
  Future<DataState<void>> call(NoParams params) => _speech.stop();
}

class WatchReadingStatusUseCase implements StreamUseCase<SpeechStatus, NoParams> {
  final SpeechRepository _speech;

  const WatchReadingStatusUseCase(this._speech);

  @override
  Stream<SpeechStatus> call(NoParams params) => _speech.watchStatus();
}
