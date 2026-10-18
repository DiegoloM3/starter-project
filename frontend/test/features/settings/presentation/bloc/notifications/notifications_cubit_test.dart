import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/usecases/get_notifications_enabled.dart';
import 'package:news_app_clean_architecture/features/settings/domain/usecases/set_notifications_enabled.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/notifications/notifications_cubit.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/notifications/notifications_state.dart';

class MockGetNotificationsEnabledUseCase extends Mock implements GetNotificationsEnabledUseCase {}

class MockSetNotificationsEnabledUseCase extends Mock implements SetNotificationsEnabledUseCase {}

void main() {
  late MockGetNotificationsEnabledUseCase getNotificationsEnabled;
  late MockSetNotificationsEnabledUseCase setNotificationsEnabled;

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    getNotificationsEnabled = MockGetNotificationsEnabledUseCase();
    setNotificationsEnabled = MockSetNotificationsEnabledUseCase();
  });

  NotificationsCubit buildCubit() => NotificationsCubit(getNotificationsEnabled, setNotificationsEnabled);

  test('starts without knowing the preference', () {
    expect(buildCubit().state, const NotificationsState());
  });

  blocTest<NotificationsCubit, NotificationsState>(
    'loads the preference',
    setUp: () => when(() => getNotificationsEnabled(any())).thenAnswer((_) async => const DataSuccess(true)),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [const NotificationsState(isEnabled: true)],
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'changes the preference at once and saves it',
    setUp: () => when(() => setNotificationsEnabled(false)).thenAnswer((_) async => const DataSuccess(null)),
    build: buildCubit,
    seed: () => const NotificationsState(isEnabled: true),
    act: (cubit) => cubit.setEnabled(false),
    expect: () => [const NotificationsState(isEnabled: false)],
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'restores the preference when it cannot be saved',
    setUp: () => when(() => setNotificationsEnabled(false)).thenAnswer((_) async => DataFailed(Exception('offline'))),
    build: buildCubit,
    seed: () => const NotificationsState(isEnabled: true),
    act: (cubit) => cubit.setEnabled(false),
    expect:
        () => [const NotificationsState(isEnabled: false), const NotificationsState(isEnabled: true, saveFailed: true)],
  );
}
