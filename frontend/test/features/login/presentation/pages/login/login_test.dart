import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/paths.dart';
import 'package:news_app_clean_architecture/features/login/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/login_bloc.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/login_field_error.dart';
import 'package:news_app_clean_architecture/features/login/presentation/pages/login/login.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations_en.dart';

class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockLoginBloc mockLoginBloc;
  late MockGoRouter mockGoRouter;
  late GetIt getIt;

  setUpAll(() {
    registerFallbackValue(LoginInitial());
    registerFallbackValue(SignOutRequested());
  });

  setUp(() {
    mockLoginBloc = MockLoginBloc();
    mockGoRouter = MockGoRouter();
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
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: InheritedGoRouter(
        goRouter: mockGoRouter,
        child: const LoginView(),
      ),
    );
  }

  Finder hintField(String hint) {
    return find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.hintText == hint,
      description: 'TextField with hint $hint',
    );
  }

  group('LoginView', () {
    testWidgets('renders email and password fields and login button',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      expect(hintField(AppLocalizationsEn().email), findsOneWidget);
      expect(hintField(AppLocalizationsEn().password), findsOneWidget);
      expect(find.text(AppLocalizationsEn().login), findsOneWidget);
      expect(find.text(AppLocalizationsEn().register), findsOneWidget);
    });

    testWidgets('adds SignInWithEmailAndPasswordRequested when login tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      await tester.enterText(
          hintField(AppLocalizationsEn().email), 'test@test.com');
      await tester.enterText(
          hintField(AppLocalizationsEn().password), 'SuperSecret123!');
      await tester.tap(find.text(AppLocalizationsEn().login));
      await tester.pump();

      verify(() => mockLoginBloc.add(
            SignInWithEmailAndPasswordRequested(
              email: 'test@test.com',
              password: 'SuperSecret123!',
            ),
          )).called(1);
    });

    testWidgets('navigates to Register page when register button is tapped',
        (WidgetTester tester) async {
      when(() => mockGoRouter.pushNamed(Paths.register.name))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(makeTestableWidget());

      await tester.tap(find.text(AppLocalizationsEn().register));
      await tester.pump();

      verify(() => mockGoRouter.pushNamed(Paths.register.name)).called(1);
    });

    testWidgets('shows validation error text for email and password fields',
        (WidgetTester tester) async {
      when(() => mockLoginBloc.state).thenReturn(
        const NotLoggedIn(
          loginErrors: [
            LoginFieldError.emailRequired,
            LoginFieldError.passwordRequired,
          ],
        ),
      );
      when(() => mockLoginBloc.stream).thenAnswer(
        (_) => Stream<LoginState>.value(
          const NotLoggedIn(
            loginErrors: [
              LoginFieldError.emailRequired,
              LoginFieldError.passwordRequired,
            ],
          ),
        ),
      );

      await tester.pumpWidget(makeTestableWidget());

      expect(find.text(AppLocalizationsEn().login_field_email_required),
          findsOneWidget);
      expect(find.text(AppLocalizationsEn().login_field_password_required),
          findsOneWidget);
    });

    testWidgets('shows loading indicator in login button when state is LoginLoading',
        (WidgetTester tester) async {
      when(() => mockLoginBloc.state).thenReturn(const LoginLoading());
      when(() => mockLoginBloc.stream)
          .thenAnswer((_) => Stream<LoginState>.value(const LoginLoading()));

      await tester.pumpWidget(makeTestableWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows login error message when state is LoginError',
        (WidgetTester tester) async {
      when(() => mockLoginBloc.state)
          .thenReturn(const LoginError(message: 'Something broke'));
      when(() => mockLoginBloc.stream).thenAnswer(
        (_) => Stream<LoginState>.value(const LoginError(message: 'Something broke')),
      );

      await tester.pumpWidget(makeTestableWidget());

      expect(find.text(AppLocalizationsEn().something_was_wrong), findsOneWidget);
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

    testWidgets('renders login form in LoggedIn state',
        (WidgetTester tester) async {
      when(() => mockLoginBloc.state).thenReturn(
        const LoggedIn(
          user: UserEntity(
            id: '1',
            email: 'test@test.com',
            name: 'Test User',
            profilePictureUrl: '',
          ),
        ),
      );
      when(() => mockLoginBloc.stream).thenAnswer(
        (_) => Stream<LoginState>.value(
          const LoggedIn(
            user: UserEntity(
              id: '1',
              email: 'test@test.com',
              name: 'Test User',
              profilePictureUrl: '',
            ),
          ),
        ),
      );

      await tester.pumpWidget(makeTestableWidget());

      expect(hintField(AppLocalizationsEn().email), findsOneWidget);
      expect(hintField(AppLocalizationsEn().password), findsOneWidget);
      expect(find.text(AppLocalizationsEn().login), findsOneWidget);
    });
  });
}
