import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:news_app_clean_architecture/core/services/connectivity_service.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityService _service;
  StreamSubscription<bool>? _subscription;

  ConnectivityBloc({required ConnectivityService service})
      : _service = service,
        super(const ConnectivityOnline()) {
    on<ConnectivityStatusChanged>(_onStatusChanged);
    _checkInitialConnection();
    _subscription = _service.onStatusChange.listen((isConnected) {
      add(ConnectivityStatusChanged(isConnected));
    });
  }

  Future<void> _checkInitialConnection() async {
    final isConnected = await _service.checkConnection();
    add(ConnectivityStatusChanged(isConnected));
  }

  void _onStatusChanged(ConnectivityStatusChanged event, Emitter<ConnectivityState> emit) {
    emit(event.isConnected ? const ConnectivityOnline() : const ConnectivityOffline());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}