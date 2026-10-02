import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_session.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/profile/profile_screen.dart';

class MockWatchSessionUseCase extends Mock implements WatchSessionUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

void main() {
  late MockSignOutUseCase signOut;
  late SessionCubit cubit;

  const jane = UserEntity(id: 'janeDoeUid', name: 'Jane Doe', email: 'jane@example.com');

  setUp(() async {
    final watchSession = MockWatchSessionUseCase();
    when(() => watchSession()).thenAnswer((_) => Stream.value(jane));
    signOut = MockSignOutUseCase();
    when(() => signOut()).thenAnswer((_) async => const DataSuccess(null));
    cubit = SessionCubit(watchSession, signOut);
    await cubit.watchSession();
  });

  tearDown(() => cubit.close());

  Future<void> openProfile(WidgetTester tester) async {
    await tester.pumpWidget(BlocProvider.value(
      value: cubit,
      child: MaterialApp(theme: lightTheme(), home: const ProfileScreen()),
    ));
  }

  testWidgets('shows the initials, the name and the email of the journalist', (tester) async {
    await openProfile(tester);

    expect(find.text('JD'), findsOneWidget);
    // In the header and in the account details.
    expect(find.text('Jane Doe'), findsNWidgets(2));
    expect(find.text('jane@example.com'), findsNWidgets(2));
  });

  testWidgets('logs out', (tester) async {
    await openProfile(tester);

    await tester.tap(find.text('Log out'));
    await tester.pump();

    verify(() => signOut()).called(1);
  });
}
