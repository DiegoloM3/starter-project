import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/profile_update.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/edit_profile/edit_profile_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/edit_profile_screen.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/screens/profile_screen.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';

import '../../../../helpers/feed_harness.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const ProfileUpdate());
  });

  testWidgets('Profile opens Edit profile; a new name is saved and the screen pops', (tester) async {
    final harness = ShellHarness();
    final updateProfile = MockUpdateProfileUseCase();
    when(() => updateProfile(any())).thenAnswer((_) async => DataSuccess(user.copyWith(displayName: 'Grace')));
    sl.registerFactoryParam<EditProfileCubit, UserEntity, void>(
      (u, _) => EditProfileCubit(updateProfile, harness.pickImage, user: u),
    );
    addTearDown(() => sl.unregister<EditProfileCubit>());
    useScreen(tester, const Size(600, 1400));
    await tester.pump();
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const ProfileScreen(),
        AppRoutes.editProfile: (_) => const EditProfileScreen(),
      },
      providers: harness.providers,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
    expect(find.text('EDIT PROFILE'), findsOneWidget);
    final save = find.widgetWithText(FilledButton, 'Save changes');
    expect(tester.widget<FilledButton>(save).enabled, isFalse);

    await tester.enterText(find.byType(TextField), 'Grace');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(save).enabled, isTrue);

    await tester.tap(find.text('Add a photo'));
    await tester.pumpAndSettle();
    verify(() => harness.pickImage(any())).called(1);

    await tester.tap(save);
    await tester.pumpAndSettle();

    final sent = verify(() => updateProfile(captureAny())).captured.single as ProfileUpdate;
    expect(sent.displayName, 'Grace');
    expect(sent.photo, buildImage());
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Profile updated'), findsOneWidget);
  });

  testWidgets('submitting from the keyboard saves, and a rejected save is announced', (tester) async {
    final harness = ShellHarness();
    final updateProfile = MockUpdateProfileUseCase();
    when(() => updateProfile(any())).thenAnswer((_) async => const DataFailed(Failure.network()));
    sl.registerFactoryParam<EditProfileCubit, UserEntity, void>(
      (u, _) => EditProfileCubit(updateProfile, harness.pickImage, user: u),
    );
    addTearDown(() => sl.unregister<EditProfileCubit>());
    useScreen(tester, const Size(600, 1400));
    await tester.pump();
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.editProfile,
      routes: {AppRoutes.editProfile: (_) => const EditProfileScreen()},
      providers: harness.providers,
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Grace');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    verify(() => updateProfile(any())).called(1);
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(find.text(FailureMessageFormatter.of(const Failure.network())), findsOneWidget);
  });
}
