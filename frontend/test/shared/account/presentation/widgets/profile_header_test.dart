import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_content_repository.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_repository.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/connect_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/delete_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/get_current_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/sign_out_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/switch_to_existing_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/update_display_name_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_cubit.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_state.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/widgets/profile_header.dart';

class _StubRepository implements AccountRepository {
  @override
  Future<DataState<AccountEntity>> getCurrentAccount() async =>
      const DataSuccess(AccountEntity(id: 'u1', isGuest: false));

  @override
  Future<DataState<AccountEntity>> updateDisplayName(String name) async =>
      DataSuccess(AccountEntity(id: 'u1', isGuest: false, displayName: name));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('rename affordance', () {
    testWidgets('a signed-in account can rename itself', (tester) async {
      await tester.pumpWidget(_app(const AccountEntity(
        id: 'u1',
        isGuest: false,
        displayName: 'Ana Diaz',
      )));

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets(
        'a guest has no name of its own to rename -- it would just be '
        'lost the moment they connect a real account', (tester) async {
      await tester
          .pumpWidget(_app(const AccountEntity(id: 'u1', isGuest: true)));

      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    });

    testWidgets(
        'saving a new name closes cleanly, dialog animation included -- '
        'regression for a real on-device freeze', (tester) async {
      // The dialog's own TextEditingController used to be disposed the
      // instant showDialog's Future resolved, while the dialog was still
      // playing its exit transition and its TextFormField was still
      // mounted and listening to it. pump() alone (a single frame) never
      // reached the frame where that broke -- only letting the closing
      // animation actually run, via pumpAndSettle, does.
      final repository = _StubRepository();
      await tester.pumpWidget(_appWithCubit(repository));
      await tester.pump(); // flushes AccountCubit's initial loadAccount()

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Jano');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('initialsFor', () {
    test('takes the first letter of the first two words of the name', () {
      const account = AccountEntity(
        id: 'u1',
        isGuest: false,
        displayName: 'ana maria diaz',
      );

      expect(initialsFor(account), 'AM');
    });

    test('falls back to the first letter of the email', () {
      const account =
          AccountEntity(id: 'u1', isGuest: false, email: 'zoe@example.com');

      expect(initialsFor(account), 'Z');
    });

    test('is null when there is nothing to take it from', () {
      expect(initialsFor(const AccountEntity(id: 'u1', isGuest: true)), isNull);
    });
  });
}

Widget _app(AccountEntity account) => MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: ProfileHeader(account: account)),
    );

Widget _appWithCubit(AccountRepository repository) => MaterialApp(
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
          body: BlocBuilder<AccountCubit, AccountState>(
            builder: (_, state) => ProfileHeader(account: state.account),
          ),
        ),
      ),
    );

class _NoContent implements AccountContentRepository {
  @override
  Future<DataState<void>> deleteAllContent() async => const DataSuccess(null);
}
