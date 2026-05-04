import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

class PublishingOverlay extends StatelessWidget {
  const PublishingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0x80000000),
      child: AbsorbPointer(
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context).publishingOverlay),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
