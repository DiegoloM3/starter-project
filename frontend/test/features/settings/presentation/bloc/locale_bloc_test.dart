import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/locale_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/get_locale_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/set_locale_preference.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/locale/locale_bloc.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/locale/locale_event.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/locale/locale_state.dart';

class _MockGet extends Mock implements GetLocalePreferenceUseCase {}

class _MockSet extends Mock implements SetLocalePreferenceUseCase {}

void main() {
  late _MockGet getUseCase;
  late _MockSet setUseCase;

  setUpAll(() {
    registerFallbackValue(LocalePreference.system);
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getUseCase = _MockGet();
    setUseCase = _MockSet();
  });

  test('initial state has system preference', () {
    final bloc = LocaleBloc(getUseCase, setUseCase);
    expect(bloc.state, const LocaleState());
    expect(bloc.state.preference, LocalePreference.system);
  });

  blocTest<LocaleBloc, LocaleState>(
    'LocaleInitialized loads the persisted preference',
    setUp: () {
      when(() => getUseCase.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(LocalePreference.spanish));
    },
    build: () => LocaleBloc(getUseCase, setUseCase),
    act: (bloc) => bloc.add(const LocaleInitialized()),
    expect: () => [const LocaleState(preference: LocalePreference.spanish)],
  );

  blocTest<LocaleBloc, LocaleState>(
    'LocaleInitialized keeps system default silently when the read fails',
    setUp: () {
      when(() => getUseCase.call(params: any(named: 'params'))).thenAnswer(
        (_) async => DataFailed(UnknownException(message: 'boom')),
      );
    },
    build: () => LocaleBloc(getUseCase, setUseCase),
    act: (bloc) => bloc.add(const LocaleInitialized()),
    expect: () => <LocaleState>[],
  );

  blocTest<LocaleBloc, LocaleState>(
    'LocalePreferenceChanged emits the new preference and persists it',
    setUp: () {
      when(() => setUseCase.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(null));
    },
    build: () => LocaleBloc(getUseCase, setUseCase),
    act: (bloc) =>
        bloc.add(const LocalePreferenceChanged(LocalePreference.english)),
    expect: () => [const LocaleState(preference: LocalePreference.english)],
    verify: (_) {
      verify(() => setUseCase.call(params: LocalePreference.english)).called(1);
    },
  );

  blocTest<LocaleBloc, LocaleState>(
    'optimistic — state updates even if persistence fails',
    setUp: () {
      when(() => setUseCase.call(params: any(named: 'params'))).thenAnswer(
        (_) async => DataFailed(UnknownException(message: 'disk full')),
      );
    },
    build: () => LocaleBloc(getUseCase, setUseCase),
    act: (bloc) =>
        bloc.add(const LocalePreferenceChanged(LocalePreference.spanish)),
    expect: () => [const LocaleState(preference: LocalePreference.spanish)],
  );
}
