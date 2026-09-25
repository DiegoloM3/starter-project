import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

typedef _PolicySection = ({String title, String body});

/// Describes what this app actually does with data -- written from the code,
/// so it has to change whenever the app starts collecting something new.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  List<_PolicySection> _sections(AppLocalizations l10n) => [
        (title: l10n.privacyAccountTitle, body: l10n.privacyAccountBody),
        (title: l10n.privacyArticlesTitle, body: l10n.privacyArticlesBody),
        (title: l10n.privacySavedTitle, body: l10n.privacySavedBody),
        (title: l10n.privacyFeedTitle, body: l10n.privacyFeedBody),
        (title: l10n.privacyStorageTitle, body: l10n.privacyStorageBody),
        (title: l10n.privacyNeverTitle, body: l10n.privacyNeverBody),
        (title: l10n.privacyDeletingTitle, body: l10n.privacyDeletingBody),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.privacyPolicy)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          for (final section in _sections(context.l10n)) ...[
            Text(section.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(section.body, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
