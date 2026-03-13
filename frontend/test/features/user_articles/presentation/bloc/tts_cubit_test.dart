import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/article_detail/tts_cubit.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/article_detail/tts_state.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late MockFlutterTts mockFlutterTts;

  setUp(() {
    mockFlutterTts = MockFlutterTts();

    // Set up default mock behavior
    when(mockFlutterTts.isLanguageAvailable(any)).thenAnswer((_) async => true);
    when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => 1);
    when(mockFlutterTts.setSpeechRate(any)).thenAnswer((_) async => 1);
    when(mockFlutterTts.setVolume(any)).thenAnswer((_) async => 1);
    when(mockFlutterTts.setPitch(any)).thenAnswer((_) async => 1);
    when(mockFlutterTts.setStartHandler(any)).thenReturn(null);
    when(mockFlutterTts.setCompletionHandler(any)).thenReturn(null);
    when(mockFlutterTts.setErrorHandler(any)).thenReturn(null);
    when(mockFlutterTts.setProgressHandler(any)).thenReturn(null);
    when(mockFlutterTts.speak(any)).thenAnswer((_) async => 1);
    when(mockFlutterTts.pause()).thenAnswer((_) async => 1);
    when(mockFlutterTts.stop()).thenAnswer((_) async => 1);
  });

  TtsCubit createCubit() => TtsCubit(flutterTts: mockFlutterTts);

  group('TtsCubit', () {
    group('initialization', () {
      test('initializes TTS with correct settings', () async {
        final cubit = createCubit();
        // Allow async initialization to complete
        await Future.delayed(const Duration(milliseconds: 50));

        verify(mockFlutterTts.isLanguageAvailable('en-US')).called(1);
        verify(mockFlutterTts.setLanguage('en-US')).called(1);
        verify(mockFlutterTts.setSpeechRate(0.5)).called(1);
        verify(mockFlutterTts.setVolume(1.0)).called(1);
        verify(mockFlutterTts.setPitch(1.0)).called(1);

        await cubit.close();
      });

      test('sets isAvailable to false when TTS not available', () async {
        when(mockFlutterTts.isLanguageAvailable(any))
            .thenAnswer((_) async => false);

        final cubit = createCubit();
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.isAvailable, false);
        expect(cubit.state.errorMessage, isNotNull);

        await cubit.close();
      });

      test('initial state has stopped status', () async {
        final cubit = createCubit();
        // Before async init, state should be default
        expect(cubit.state.status, TtsStatus.stopped);
        // Wait for async init to complete before closing
        await Future.delayed(const Duration(milliseconds: 50));
        await cubit.close();
      });
    });

    group('prepareText', () {
      test('prepares text and calculates estimated duration', () async {
        final cubit = createCubit();
        await Future.delayed(const Duration(milliseconds: 50));

        const testText = 'This is a test text with several words in it';
        cubit.prepareText(testText);

        expect(cubit.state.totalDuration.inSeconds, greaterThan(0));
        expect(cubit.state.currentPosition, Duration.zero);
        expect(cubit.state.status, TtsStatus.stopped);

        await cubit.close();
      });
    });

    group('play', () {
      blocTest<TtsCubit, TtsState>(
        'emits loading when play is called with prepared text',
        build: () => createCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) {
          cubit.prepareText('Test text');
          return cubit.play();
        },
        expect: () => [
          // From prepareText
          predicate<TtsState>((state) =>
              state.status == TtsStatus.stopped &&
              state.totalDuration.inSeconds > 0),
          // From play
          predicate<TtsState>((state) => state.status == TtsStatus.loading),
        ],
        verify: (_) {
          verify(mockFlutterTts.speak('Test text')).called(1);
        },
      );

      test('does nothing when no text is prepared', () async {
        final cubit = createCubit();
        await Future.delayed(const Duration(milliseconds: 50));

        await cubit.play();
        // State should still be from initialization, not loading
        expect(cubit.state.status, isNot(TtsStatus.loading));
        verifyNever(mockFlutterTts.speak(any));

        await cubit.close();
      });
    });

    group('pause', () {
      blocTest<TtsCubit, TtsState>(
        'emits paused status when pause succeeds',
        build: () => createCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.pause(),
        expect: () => [
          predicate<TtsState>((state) => state.status == TtsStatus.paused),
        ],
        verify: (_) {
          verify(mockFlutterTts.pause()).called(1);
        },
      );
    });

    group('stop', () {
      blocTest<TtsCubit, TtsState>(
        'emits stopped status and resets position',
        build: () => createCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.stop(),
        expect: () => [
          predicate<TtsState>((state) =>
              state.status == TtsStatus.stopped &&
              state.currentPosition == Duration.zero),
        ],
      );
    });

    group('togglePlayPause', () {
      blocTest<TtsCubit, TtsState>(
        'pauses when currently playing',
        build: () => createCubit(),
        wait: const Duration(milliseconds: 50),
        seed: () => const TtsState(status: TtsStatus.playing),
        act: (cubit) => cubit.togglePlayPause(),
        expect: () => [
          predicate<TtsState>((state) => state.status == TtsStatus.paused),
        ],
      );
    });

    group('setPlaybackSpeed', () {
      blocTest<TtsCubit, TtsState>(
        'sets playback speed and updates TTS rate',
        build: () => createCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.setPlaybackSpeed(1.5),
        expect: () => [
          predicate<TtsState>((state) => state.playbackSpeed == 1.5),
        ],
        verify: (_) {
          // Speed 1.5 * 0.5 = 0.75 (TTS uses 0-1 range)
          verify(mockFlutterTts.setSpeechRate(0.75)).called(1);
        },
      );

      blocTest<TtsCubit, TtsState>(
        'clamps speed to valid range',
        build: () => createCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.setPlaybackSpeed(5.0),
        expect: () => [
          predicate<TtsState>(
              (state) => state.playbackSpeed == 2.0), // clamped to max
        ],
      );
    });

    group('clearError', () {
      blocTest<TtsCubit, TtsState>(
        'clears error message',
        build: () => createCubit(),
        wait: const Duration(milliseconds: 50),
        seed: () => const TtsState(
          status: TtsStatus.error,
          errorMessage: 'Some error',
        ),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          predicate<TtsState>((state) => state.errorMessage == null),
        ],
      );
    });

    group('TtsState', () {
      test('isPlaying returns correct value', () {
        const playing = TtsState(status: TtsStatus.playing);
        expect(playing.isPlaying, true);

        const stopped = TtsState(status: TtsStatus.stopped);
        expect(stopped.isPlaying, false);
      });

      test('isPaused returns correct value', () {
        const paused = TtsState(status: TtsStatus.paused);
        expect(paused.isPaused, true);

        const playing = TtsState(status: TtsStatus.playing);
        expect(playing.isPaused, false);
      });

      test('canPlay returns correct value', () {
        const stopped = TtsState(status: TtsStatus.stopped, isAvailable: true);
        expect(stopped.canPlay, true);

        const paused = TtsState(status: TtsStatus.paused, isAvailable: true);
        expect(paused.canPlay, true);

        const playing = TtsState(status: TtsStatus.playing, isAvailable: true);
        expect(playing.canPlay, false);

        const unavailable =
            TtsState(status: TtsStatus.stopped, isAvailable: false);
        expect(unavailable.canPlay, false);
      });

      test('progress calculates correctly', () {
        const state = TtsState(
          currentPosition: Duration(seconds: 30),
          totalDuration: Duration(seconds: 60),
        );
        expect(state.progress, 0.5);

        const zeroDuration = TtsState(totalDuration: Duration.zero);
        expect(zeroDuration.progress, 0.0);
      });

      test('formatted duration returns correct format', () {
        const state = TtsState(
          currentPosition: Duration(minutes: 1, seconds: 30),
          totalDuration: Duration(minutes: 3, seconds: 45),
        );
        expect(state.formattedPosition, '01:30');
        expect(state.formattedDuration, '03:45');
      });
    });
  });
}
