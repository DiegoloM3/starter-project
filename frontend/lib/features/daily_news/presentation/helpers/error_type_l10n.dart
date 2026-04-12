import 'package:flutter/widgets.dart';
import 'package:news_app_clean_architecture/core/resources/error_type.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

extension ErrorTypeL10n on ErrorType {
  String toMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (this) {
      ErrorType.network => l10n.errorNetwork,
      ErrorType.server => l10n.errorServer,
      ErrorType.storage => l10n.errorStorage,
      ErrorType.notFound => l10n.errorNotFound,
      ErrorType.unknown => l10n.genericError,
    };
  }
}
