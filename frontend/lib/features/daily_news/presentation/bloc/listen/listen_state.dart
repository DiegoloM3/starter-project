part of 'listen_cubit.dart';

class ListenState extends Equatable {
  final SpeechStatus status;

  /// Identifier of what is being read (article id, brief card id).
  final String? currentId;
  final Failure? failure;

  const ListenState({this.status = SpeechStatus.idle, this.currentId, this.failure});

  bool get isSpeaking => status == SpeechStatus.speaking;

  ListenState copyWith({
    SpeechStatus? status,
    String? currentId,
    bool clearCurrent = false,
    Failure? failure,
  }) {
    return ListenState(
      status: status ?? this.status,
      currentId: clearCurrent ? null : (currentId ?? this.currentId),
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, currentId, failure];
}
