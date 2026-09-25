import 'package:equatable/equatable.dart';

/// The device's connectivity right now. [offlineSince] holds still at the
/// moment it dropped -- it's "offline since", not "last checked" -- so a
/// banner showing it doesn't creep forward on every rebuild.
class ConnectivityStatus extends Equatable {
  final bool isOnline;
  final DateTime? offlineSince;

  const ConnectivityStatus({required this.isOnline, this.offlineSince});

  const ConnectivityStatus.online() : this(isOnline: true);

  @override
  List<Object?> get props => [isOnline, offlineSince];
}
