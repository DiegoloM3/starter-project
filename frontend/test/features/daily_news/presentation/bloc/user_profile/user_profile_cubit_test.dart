import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/user_profile/user_profile_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/user_profile/user_profile_state.dart';

void main() {
  group('UserProfileCubit', () {
    late UserProfileCubit cubit;

    setUp(() {
      cubit = UserProfileCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has no name or email', () {
      expect(cubit.state.name, isNull);
      expect(cubit.state.email, isNull);
      expect(cubit.state.hasProfile, false);
    });

    test('updateProfile sets name', () {
      cubit.updateProfile(name: 'Maria');

      expect(cubit.state.name, 'Maria');
      expect(cubit.state.displayName, 'Maria');
      expect(cubit.state.hasProfile, true);
    });

    test('updateProfile sets email', () {
      cubit.updateProfile(email: 'maria@test.com');

      expect(cubit.state.email, 'maria@test.com');
      expect(cubit.state.displayEmail, 'maria@test.com');
      expect(cubit.state.hasProfile, true);
    });

    test('updateProfile sets both name and email', () {
      cubit.updateProfile(name: 'Maria', email: 'maria@test.com');

      expect(cubit.state.name, 'Maria');
      expect(cubit.state.email, 'maria@test.com');
    });

    test('updateProfile ignores empty name', () {
      cubit.updateProfile(name: 'Maria');
      cubit.updateProfile(name: '');

      expect(cubit.state.name, 'Maria');
    });

    test('updateProfile ignores empty email', () {
      cubit.updateProfile(email: 'maria@test.com');
      cubit.updateProfile(email: '');

      expect(cubit.state.email, 'maria@test.com');
    });

    test('updateProfile preserves existing name when only email is given', () {
      cubit.updateProfile(name: 'Maria');
      cubit.updateProfile(email: 'maria@test.com');

      expect(cubit.state.name, 'Maria');
      expect(cubit.state.email, 'maria@test.com');
    });
  });

  group('UserProfileState', () {
    test('displayName returns null when no name set', () {
      const state = UserProfileState();

      expect(state.displayName, isNull);
    });

    test('displayName returns name when set', () {
      const state = UserProfileState(name: 'Maria');

      expect(state.displayName, 'Maria');
    });

    test('displayName returns null for empty name', () {
      const state = UserProfileState(name: '');

      expect(state.displayName, isNull);
    });

    test('displayEmail returns empty string when no email set', () {
      const state = UserProfileState();

      expect(state.displayEmail, '');
    });

    test('displayEmail returns email when set', () {
      const state = UserProfileState(email: 'maria@test.com');

      expect(state.displayEmail, 'maria@test.com');
    });

    test('hasProfile returns false when both are null', () {
      const state = UserProfileState();

      expect(state.hasProfile, false);
    });

    test('hasProfile returns false when both are empty', () {
      const state = UserProfileState(name: '', email: '');

      expect(state.hasProfile, false);
    });

    test('hasProfile returns true when name is set', () {
      const state = UserProfileState(name: 'Maria');

      expect(state.hasProfile, true);
    });

    test('hasProfile returns true when email is set', () {
      const state = UserProfileState(email: 'maria@test.com');

      expect(state.hasProfile, true);
    });

    test('copyWith preserves existing values', () {
      const original = UserProfileState(name: 'Maria', email: 'a@b.com');
      final copied = original.copyWith();

      expect(copied.name, 'Maria');
      expect(copied.email, 'a@b.com');
    });

    test('copyWith overrides specified values', () {
      const original = UserProfileState(name: 'Maria');
      final copied = original.copyWith(email: 'new@test.com');

      expect(copied.name, 'Maria');
      expect(copied.email, 'new@test.com');
    });

    test('equality works correctly', () {
      const a = UserProfileState(name: 'Maria', email: 'a@b.com');
      const b = UserProfileState(name: 'Maria', email: 'a@b.com');
      const c = UserProfileState(name: 'Juan', email: 'a@b.com');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
