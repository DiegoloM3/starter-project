import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/login/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/login_bloc.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/register_field_error.dart';
import 'package:news_app_clean_architecture/features/login/presentation/pages/register/register.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations_en.dart';

class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}

void main() {
  late MockLoginBloc mockLoginBloc;
  late GetIt getIt;

  setUpAll(() {
    registerFallbackValue(LoginInitial());
    registerFallbackValue(
      CreateUserRequested(
        user: const UserEntity(id: '', email: '', name: ''),
        password: '',
      ),
    );
  });

  setUp(() {
    mockLoginBloc = MockLoginBloc();
    getIt = GetIt.instance;
    if (getIt.isRegistered<LoginBloc>()) {
      getIt.unregister<LoginBloc>();
    }
    getIt.registerSingleton<LoginBloc>(mockLoginBloc);

    when(() => mockLoginBloc.state).thenReturn(LoginInitial());
    when(() => mockLoginBloc.stream)
        .thenAnswer((_) => Stream<LoginState>.value(LoginInitial()));
  });

  tearDown(() {
    if (getIt.isRegistered<LoginBloc>()) {
      getIt.unregister<LoginBloc>();
    }
  });

  Widget makeTestableWidget() {
    return const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RegisterView(),
    );
  }

  Finder hintField(String hint) {
    return find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.hintText == hint,
      description: 'TextField with hint $hint',
    );
  }

  group('RegisterView', () {
    testWidgets('renders name, email and password fields and register button',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      expect(hintField(AppLocalizationsEn().name), findsOneWidget);
      expect(hintField(AppLocalizationsEn().email), findsOneWidget);
      expect(hintField(AppLocalizationsEn().password), findsOneWidget);
      expect(find.text(AppLocalizationsEn().register), findsOneWidget);
    });

    testWidgets('adds CreateUserRequested when register button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      await tester.enterText(hintField(AppLocalizationsEn().name), 'Test User');
      await tester.enterText(
          hintField(AppLocalizationsEn().email), 'test@test.com');
      await tester.enterText(
          hintField(AppLocalizationsEn().password), 'SuperSecret123!');
      await tester.tap(find.text(AppLocalizationsEn().register));
      await tester.pump();

      verify(() => mockLoginBloc.add(
            CreateUserRequested(
              user: const UserEntity(
                id: '',
                email: 'test@test.com',
                name: 'Test User',
              ),
              password: 'SuperSecret123!',
            ),
          )).called(1);
    });

    testWidgets(
        'shows validation error text for name, email and password fields',
        (WidgetTester tester) async {
      when(() => mockLoginBloc.state).thenReturn(
        const NotLoggedIn(
          registerErrors: [
            RegisterFieldError.nameRequired,
            RegisterFieldError.emailRequired,
            RegisterFieldError.passwordRequired,
          ],
        ),
      );
      when(() => mockLoginBloc.stream).thenAnswer(
        (_) => Stream<LoginState>.value(
          const NotLoggedIn(
            registerErrors: [
              RegisterFieldError.nameRequired,
              RegisterFieldError.emailRequired,
              RegisterFieldError.passwordRequired,
            ],
          ),
        ),
      );

      await tester.pumpWidget(makeTestableWidget());

      expect(find.text(AppLocalizationsEn().register_field_name_required),
          findsOneWidget);
      expect(find.text(AppLocalizationsEn().register_field_email_required),
          findsOneWidget);
      expect(find.text(AppLocalizationsEn().register_field_password_required),
          findsOneWidget);
    });

    testWidgets(
        'shows loading indicator in register button when state is LoginLoading',
        (WidgetTester tester) async {
      when(() => mockLoginBloc.state).thenReturn(const LoginLoading());
      when(() => mockLoginBloc.stream)
          .thenAnswer((_) => Stream<LoginState>.value(const LoginLoading()));

      await tester.pumpWidget(makeTestableWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('password field toggles visibility when suffix icon is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      final passwordFieldFinder = hintField(AppLocalizationsEn().password);
      TextField passwordField = tester.widget<TextField>(passwordFieldFinder);
      expect(passwordField.obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      passwordField = tester.widget<TextField>(passwordFieldFinder);
      expect(passwordField.obscureText, isFalse);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      passwordField = tester.widget<TextField>(passwordFieldFinder);
      expect(passwordField.obscureText, isTrue);
    });
  });
}
