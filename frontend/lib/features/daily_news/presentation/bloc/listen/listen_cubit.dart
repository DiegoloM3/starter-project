import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/speech_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/control_reading.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/read_aloud.dart';

part 'listen_state.dart';

/// The one voice of the app. App-wide so a Brief card and the Reader never
/// talk over each other: starting a new text stops the previous one.
class ListenCubit extends Cubit<ListenState> {
  final ReadAloudUseCase _readAloud;
  final PauseReadingUseCase _pause;
  final ResumeReadingUseCase _resume;
  final StopReadingUseCase _stop;
  StreamSubscription<SpeechStatus>? _subscription;

  ListenCubit(
    this._readAloud,
    this._pause,
    this._resume,
    this._stop,
    WatchReadingStatusUseCase watchStatus,
  ) : super(const ListenState()) {
    _subscription = watchStatus(const NoParams()).listen(_onStatus);
  }

  void _onStatus(SpeechStatus status) {
    emit(state.copyWith(
      status: status,
      clearCurrent: status == SpeechStatus.idle,
    ));
  }

  bool isReading(String id) => state.currentId == id && state.status != SpeechStatus.idle;

  /// Play / pause for one piece of content identified by [id].
  Future<void> toggle({required String id, required String text, double rate = 1}) async {
    if (state.currentId == id) {
      final result = state.status == SpeechStatus.speaking
          ? await _pause(const NoParams())
          : await _resume(const NoParams());
      _report(result);
      return;
    }
    emit(state.copyWith(currentId: id, status: SpeechStatus.speaking));
    _report(await _readAloud(ReadAloudParams(text: text, rate: rate)));
  }

  Future<void> stop() async {
    if (state.status == SpeechStatus.idle) return;
    _report(await _stop(const NoParams()));
  }

  void _report(DataState<void> result) {
    if (isClosed) return;
    if (result is DataFailed<void>) {
      emit(state.copyWith(status: SpeechStatus.idle, clearCurrent: true, failure: result.failure));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
