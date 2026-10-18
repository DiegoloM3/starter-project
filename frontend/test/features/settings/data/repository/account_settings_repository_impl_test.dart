import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/data/data_sources/remote/account_settings_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/settings/data/repository/account_settings_repository_impl.dart';

class MockAccountSettingsRemoteDataSource extends Mock implements AccountSettingsRemoteDataSource {}

void main() {
  late MockAccountSettingsRemoteDataSource dataSource;
  late AccountSettingsRepositoryImpl repository;

  setUp(() {
    dataSource = MockAccountSettingsRemoteDataSource();
    repository = AccountSettingsRepositoryImpl(dataSource);
  });

  test('reads the notifications preference', () async {
    when(() => dataSource.readNotificationsEnabled()).thenAnswer((_) async => true);

    expect((await repository.getNotificationsEnabled()).data, isTrue);
  });

  test('writes the notifications preference', () async {
    when(() => dataSource.writeNotificationsEnabled(false)).thenAnswer((_) async {});

    expect(await repository.setNotificationsEnabled(false), isA<DataSuccess>());
  });

  test('fails with the exception of the data source', () async {
    final error = Exception('offline');
    when(() => dataSource.readNotificationsEnabled()).thenThrow(error);

    expect((await repository.getNotificationsEnabled()).error, error);
  });
}
