import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_exception.dart';

extension AccountErrorMessage on AccountErrorReason {
  String messageIn(AppLocalizations l10n) => switch (this) {
        AccountErrorReason.wrongCredentials => l10n.errorWrongCredentials,
        AccountErrorReason.differentAccount =>
          l10n.errorDifferentAccount,
        AccountErrorReason.weakPassword =>
          l10n.errorWeakPassword,
        AccountErrorReason.invalidEmail => l10n.errorInvalidEmail,
        AccountErrorReason.otherSignInMethod =>
          l10n.errorOtherSignInMethod,
        AccountErrorReason.methodNotAvailable =>
          l10n.errorMethodNotAvailable,
        AccountErrorReason.network =>
          l10n.errorNetwork,
        AccountErrorReason.tooManyAttempts =>
          l10n.errorTooManyAttempts,
        AccountErrorReason.cancelled ||
        AccountErrorReason.existingAccount ||
        AccountErrorReason.unknown =>
          l10n.genericError,
      };
}
