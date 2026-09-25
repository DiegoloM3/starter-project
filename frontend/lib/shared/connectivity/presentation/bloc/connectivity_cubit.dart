import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/connectivity_status.dart';
import '../../domain/usecases/watch_connectivity_usecase.dart';

/// Whether the device is online, kept live for the whole app session -- so
/// a screen can react the moment a connection drops, not only the next
/// time it happens to fetch something.
class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  final WatchConnectivityUseCase _watchConnectivityUseCase;
  StreamSubscription<bool>? _subscription;

  ConnectivityCubit(this._watchConnectivityUseCase)
      : super(const ConnectivityStatus.online()) {
    _subscription = _watchConnectivityUseCase().listen(_onChanged);
  }

  void _onChanged(bool isOnline) {
    if (isOnline) {
      emit(const ConnectivityStatus.online());
    } else if (state.isOnline) {
      emit(ConnectivityStatus(isOnline: false, offlineSince: DateTime.now()));
    }
    // Already offline and still offline: leave offlineSince as it was.
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
