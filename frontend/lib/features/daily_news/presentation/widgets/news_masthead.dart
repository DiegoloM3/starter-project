import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

/// Today's date over the paper's name, like a newspaper's front page. Kept
/// compact: it stays fixed above the feed.
class NewsMasthead extends StatelessWidget {
  /// Tapping the paper's name, like tapping a status bar on iOS.
  final VoidCallback? onTap;
  final VoidCallback? onSearch;

  const NewsMasthead({super.key, this.onTap, this.onSearch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      DateFormat.MMMMEEEEd()
                          .format(DateTime.now())
                          .toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    // The app's name on purpose, in every language.
                    child: Text.rich(
                      TextSpan(
                        style: theme.textTheme.displayLarge
                            ?.copyWith(fontSize: 28, height: 1.1),
                        children: [
                          const TextSpan(text: 'Daily '),
                          TextSpan(
                            text: 'News',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (onSearch != null)
                    IconButton(
                      tooltip: context.l10n.searchAction,
                      icon: const Icon(Icons.search),
                      onPressed: onSearch,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
