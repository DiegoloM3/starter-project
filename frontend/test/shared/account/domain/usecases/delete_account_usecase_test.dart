import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/sign_in_method.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_content_repository.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_repository.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/delete_account_usecase.dart';

const _guest = AccountEntity(id: 'new-guest', isGuest: true);

/// Records every call into one shared log, so a test can check the order.
class _FakeAccountRepository implements AccountRepository {
  final List<String> log;
  final bool reauthenticationFails;

  _FakeAccountRepository(this.log, {this.reauthenticationFails = false});

  @override
  Future<DataState<void>> reauthenticate(SignInMethod method) async {
    log.add('reauthenticate');
    return reauthenticationFails
        ? DataFailed(Exception('wrong password'))
        : const DataSuccess(null);
  }

  @override
  Future<DataState<AccountEntity>> deleteAccount() async {
    log.add('deleteAccount');
    return const DataSuccess(_guest);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeContentRepository implements AccountContentRepository {
  final List<String> log;
  final bool fails;

  _FakeContentRepository(this.log, {this.fails = false});

  @override
  Future<DataState<void>> deleteAllContent() async {
    log.add('deleteAllContent');
    return fails ? DataFailed(Exception('offline')) : const DataSuccess(null);
  }
}

void main() {
  const password = EmailSignInMethod(email: 'a@b.com', password: 'secret');

  test('confirms identity, then deletes the content, then the account',
      () async {
    final log = <String>[];
    final useCase = DeleteAccountUseCase(
      _FakeAccountRepository(log),
      _FakeContentRepository(log),
    );

    final result = await useCase(params: password);

    expect(log, ['reauthenticate', 'deleteAllContent', 'deleteAccount']);
    expect(result.data, _guest);
  });

  test('deletes nothing when the identity check fails', () async {
    final log = <String>[];
    final useCase = DeleteAccountUseCase(
      _FakeAccountRepository(log, reauthenticationFails: true),
      _FakeContentRepository(log),
    );

    final result = await useCase(params: password);

    expect(log, ['reauthenticate']);
    expect(result, isA<DataFailed<AccountEntity>>());
  });

  test('keeps the account when its content could not be deleted', () async {
    final log = <String>[];
    final useCase = DeleteAccountUseCase(
      _FakeAccountRepository(log),
      _FakeContentRepository(log, fails: true),
    );

    final result = await useCase(params: password);

    expect(log, ['reauthenticate', 'deleteAllContent']);
    expect(result, isA<DataFailed<AccountEntity>>());
  });

  test('a guest skips the identity check', () async {
    final log = <String>[];
    final useCase = DeleteAccountUseCase(
      _FakeAccountRepository(log),
      _FakeContentRepository(log),
    );

    await useCase();

    expect(log, ['deleteAllContent', 'deleteAccount']);
  });
}
