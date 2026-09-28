import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/home/presentation/widgets/sidebar_menu.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {
  final List<AuthEvent> addedEvents = [];

  @override
  void add(AuthEvent event) {
    addedEvents.add(event);
    super.add(event);
  }
}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget buildWidget({Widget? child, VoidCallback? onItemSelected}) {
    return MaterialApp(
      routes: {
        '/Login': (_) => const Scaffold(body: Text('Login Screen')),
        '/Register': (_) => const Scaffold(body: Text('Register Screen')),
        '/SavedArticles': (_) => const Scaffold(body: Text('Saved Articles Screen')),
        '/CreateArticle': (_) => const Scaffold(body: Text('Create Article Screen')),
      },
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: child ?? SidebarMenu(onItemSelected: onItemSelected),
      ),
    );
  }

  testWidgets('displays Guest state and NOT LOGGED IN badge when unauthenticated',
      (tester) async {
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('Guest Reader'), findsOneWidget);
    expect(find.text('Browse news anonymously'), findsOneWidget);
    expect(find.text('NOT LOGGED IN'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Daily News'), findsOneWidget);
    expect(find.text('Saved Articles'), findsOneWidget);
    expect(find.text('Write Article'), findsOneWidget);
  });

  testWidgets('displays user profile and LOGGED IN badge when authenticated',
      (tester) async {
    const user = UserEntity(
      id: '123',
      email: 'alex@example.com',
      displayName: 'Alex Rivers',
    );
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const Authenticated(user),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('Alex Rivers'), findsOneWidget);
    expect(find.text('alex@example.com'), findsOneWidget);
    expect(find.text('LOGGED IN'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
    expect(find.text('Sign In'), findsNothing);
  });

  testWidgets('dispatches LogoutRequested when Sign Out is tapped',
      (tester) async {
    const user = UserEntity(
      id: '123',
      email: 'alex@example.com',
      displayName: 'Alex Rivers',
    );
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const Authenticated(user),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    expect(mockAuthBloc.addedEvents, contains(const LogoutRequested()));
  });

  testWidgets('navigates to Login when Sign In button is tapped',
      (tester) async {
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Login Screen'), findsOneWidget);
  });

  testWidgets('navigates to Register when Register button is tapped',
      (tester) async {
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Register Screen'), findsOneWidget);
  });

  testWidgets('invokes onItemSelected and navigates when menu items are tapped',
      (tester) async {
    bool callbackInvoked = false;
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    await tester.pumpWidget(buildWidget(
      onItemSelected: () => callbackInvoked = true,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Saved Articles'));
    await tester.pumpAndSettle();

    expect(callbackInvoked, isTrue);
    expect(find.text('Saved Articles Screen'), findsOneWidget);
  });
}
