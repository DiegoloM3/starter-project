part of 'connectivity_bloc.dart';

@immutable
sealed class ConnectivityState {
  const ConnectivityState();
}

class ConnectivityOnline extends ConnectivityState {
  const ConnectivityOnline();
}

class ConnectivityOffline extends ConnectivityState {
  const ConnectivityOffline();
}