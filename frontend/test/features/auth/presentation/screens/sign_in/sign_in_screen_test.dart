import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/auth_validation.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_form/auth_form_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_form/auth_form_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/sign_in/sign_in_screen.dart';

class MockAuthFormCubit extends MockCubit<AuthFormState> implements AuthFormCubit {}

void main() {
  late MockAuthFormCubit authFormCubit;

  setUp(() {
    authFormCubit = MockAuthFormCubit();
    when(
      () => authFormCubit.signIn(email: any(named: 'email'), password: any(named: 'password')),
    ).thenAnswer((_) async {});
  });

  Future<void> pumpSignInScreen(WidgetTester tester, AuthFormState state) {
    when(() => authFormCubit.state).thenReturn(state);
    return tester.pumpWidget(
      MaterialApp(home: BlocProvider<AuthFormCubit>.value(value: authFormCubit, child: const SignInScreen())),
    );
  }

  testWidgets('submits the typed email and password', (tester) async {
    await pumpSignInScreen(tester, const AuthFormState());

    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'jane@test.com');
    await tester.enterText(find.widgetWithText(TextField, 'Contraseña'), 'password');
    await tester.tap(find.text('INICIAR SESIÓN'));

    verify(() => authFormCubit.signIn(email: 'jane@test.com', password: 'password')).called(1);
  });

  testWidgets('shows the validation errors below their fields', (tester) async {
    const state = AuthFormState(
      status: AuthFormStatus.failure,
      validationErrors: {AuthValidationError.emailInvalid, AuthValidationError.passwordEmpty},
    );

    await pumpSignInScreen(tester, state);

    expect(find.text('Escribe un email válido.'), findsOneWidget);
    expect(find.text('Escribe tu contraseña.'), findsOneWidget);
  });
}
