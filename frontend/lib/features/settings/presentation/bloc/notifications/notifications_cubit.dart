import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/resources/data_state.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/get_notifications_enabled.dart';
import '../../../domain/usecases/set_notifications_enabled.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsEnabledUseCase _getNotificationsEnabledUseCase;
  final SetNotificationsEnabledUseCase _setNotificationsEnabledUseCase;

  NotificationsCubit(this._getNotificationsEnabledUseCase, this._setNotificationsEnabledUseCase)
    : super(const NotificationsState());

  Future<void> load() async {
    final result = await _getNotificationsEnabledUseCase(const NoParams());
    if (result is DataSuccess) emit(NotificationsState(isEnabled: result.data));
  }

  /// Shows the change at once and restores the previous value if it cannot be saved.
  Future<void> setEnabled(bool isEnabled) async {
    final previousValue = state.isEnabled;
    emit(NotificationsState(isEnabled: isEnabled));
    final result = await _setNotificationsEnabledUseCase(isEnabled);
    if (result is DataFailed) emit(NotificationsState(isEnabled: previousValue, saveFailed: true));
  }
}
