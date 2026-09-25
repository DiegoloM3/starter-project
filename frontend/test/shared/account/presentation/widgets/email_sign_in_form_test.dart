import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/sign_in_method.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_content_repository.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_repository.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/connect_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/delete_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/get_current_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/sign_out_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/switch_to_existing_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/update_display_name_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_cubit.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/widgets/email_sign_in_form.dart';

/// Records whatever [SignInMethod] the form actually submits, so the test
/// can check what reaches the repository, not just what's on screen.
class _RecordingRepository implements AccountRepository {
  SignInMethod? lastConnect;

  @override
  Future<DataState<AccountEntity>> connect(SignInMethod method) async {
    lastConnect = method;
    return const DataSuccess(AccountEntity(id: 'u1', isGuest: false));
  }

  @override
  Future<DataState<AccountEntity>> getCurrentAccount() async =>
      const DataSuccess(AccountEntity(id: 'guest', isGuest: true));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _RecordingRepository repository;

  Widget app() {
    repository = _RecordingRepository();
    return MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: BlocProvider(
        create: (_) => AccountCubit(
          GetCurrentAccountUseCase(repository),
          ConnectAccountUseCase(repository),
          SwitchToExistingAccountUseCase(repository),
          SignOutUseCase(repository),
          DeleteAccountUseCase(repository, _NoContent()),
          UpdateDisplayNameUseCase(repository),
        ),
        child: Scaffold(
          body: EmailSignInForm(
            isBusy: false,
            errorText: null,
            onBack: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('signing in asks for email and password only, no name field',
      (tester) async {
    await tester.pumpWidget(app());

    expect(find.text('Your name'), findsNothing);
  });

  testWidgets('creating an account also asks for a name', (tester) async {
    await tester.pumpWidget(app());

    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(find.text('Your name'), findsOneWidget);
  });

  testWidgets('a blank name blocks account creation', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('Create account'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(1), 'a@b.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'secret1');
    await tester.enterText(find.byType(TextFormField).at(3), 'secret1');

    await tester.tap(find.text('Create account').last);
    await tester.pump();

    expect(find.text('Required'), findsOneWidget);
    expect(repository.lastConnect, isNull);
  });

  testWidgets('the typed name reaches the account as its display name',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('Create account'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(0), 'Ana Diaz');
    await tester.enterText(find.byType(TextFormField).at(1), 'a@b.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'secret1');
    await tester.enterText(find.byType(TextFormField).at(3), 'secret1');

    await tester.tap(find.text('Create account').last);
    await tester.pump();

    final method = repository.lastConnect;
    expect(method, isA<EmailSignInMethod>());
    expect((method as EmailSignInMethod).displayName, 'Ana Diaz');
  });

  testWidgets('signing in (not creating) never sends a display name',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret1');

    await tester.tap(find.text('Sign in').last);
    await tester.pump();

    final method = repository.lastConnect;
    expect((method as EmailSignInMethod).displayName, isNull);
  });
}

class _NoContent implements AccountContentRepository {
  @override
  Future<DataState<void>> deleteAllContent() async => const DataSuccess(null);
}
