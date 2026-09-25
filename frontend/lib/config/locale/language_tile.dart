import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

import 'locale_cubit.dart';

/// The profile's language row. Each language is named in itself ("Español",
/// not "Spanish"), so it's recognizable whichever one is on screen.
class LanguageTile extends StatelessWidget {
  static const _names = {'en': 'English', 'es': 'Español'};

  const LanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) => ListTile(
        leading: const Icon(Icons.language),
        title: Text(context.l10n.language),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_names[locale.languageCode] ?? locale.languageCode),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => unawaited(_chooseLanguage(context, locale)),
      ),
    );
  }

  Future<void> _chooseLanguage(BuildContext context, Locale current) async {
    final cubit = context.read<LocaleCubit>();
    final chosen = await showDialog<Locale>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(dialogContext.l10n.language),
        children: [
          for (final locale in LocaleCubit.supportedLocales)
            ListTile(
              title: Text(_names[locale.languageCode]!),
              trailing: locale == current ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(dialogContext, locale),
            ),
        ],
      ),
    );
    if (chosen != null) cubit.select(chosen);
  }
}
