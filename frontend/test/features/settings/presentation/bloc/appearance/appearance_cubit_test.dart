import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/appearance.dart';
import 'package:news_app_clean_architecture/features/settings/domain/usecases/get_appearance.dart';
import 'package:news_app_clean_architecture/features/settings/domain/usecases/save_appearance.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/appearance/appearance_cubit.dart';

class MockGetAppearanceUseCase extends Mock implements GetAppearanceUseCase {}

class MockSaveAppearanceUseCase extends Mock implements SaveAppearanceUseCase {}

void main() {
  late MockGetAppearanceUseCase getAppearance;
  late MockSaveAppearanceUseCase saveAppearance;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(Appearance.light);
  });

  setUp(() {
    getAppearance = MockGetAppearanceUseCase();
    saveAppearance = MockSaveAppearanceUseCase();
  });

  AppearanceCubit buildCubit() => AppearanceCubit(getAppearance, saveAppearance);

  test('starts with the light appearance', () {
    expect(buildCubit().state, Appearance.light);
  });

  blocTest<AppearanceCubit, Appearance>(
    'loads the saved appearance',
    setUp: () => when(() => getAppearance(any())).thenAnswer((_) async => const DataSuccess(Appearance.dark)),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [Appearance.dark],
  );

  blocTest<AppearanceCubit, Appearance>(
    'keeps the light appearance when it cannot be loaded',
    setUp: () => when(() => getAppearance(any())).thenAnswer((_) async => DataFailed(Exception('storage'))),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => <Appearance>[],
  );

  blocTest<AppearanceCubit, Appearance>(
    'shows the chosen appearance at once and saves it',
    setUp: () => when(() => saveAppearance(any())).thenAnswer((_) async => const DataSuccess(null)),
    build: buildCubit,
    act: (cubit) => cubit.choose(Appearance.dark),
    expect: () => [Appearance.dark],
    verify: (_) => verify(() => saveAppearance(Appearance.dark)).called(1),
  );
}
