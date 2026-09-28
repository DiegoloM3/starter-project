part of 'connectivity_bloc.dart';

@immutable
sealed class ConnectivityEvent {
  const ConnectivityEvent();
}

class ConnectivityStatusChanged extends ConnectivityEvent {
  final bool isConnected;
  const ConnectivityStatusChanged(this.isConnected);
}