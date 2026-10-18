import 'package:equatable/equatable.dart';

class NotificationsState extends Equatable {
  /// Null until the preference is loaded.
  final bool? isEnabled;

  final bool saveFailed;

  const NotificationsState({this.isEnabled, this.saveFailed = false});

  @override
  List<Object?> get props => [isEnabled, saveFailed];
}
