import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

class RouteNotFoundPage extends StatelessWidget {
  final String? routeName;

  const RouteNotFoundPage({
    Key? key,
    required this.routeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Text(l10n.pageNotFound),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.pageNotFound,
                textAlign: TextAlign.center,
                style: tt.titleMedium?.copyWith(color: cs.onSurface),
              ),
              if (routeName != null) ...[
                const SizedBox(height: 8),
                Text(
                  routeName!,
                  textAlign: TextAlign.center,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
