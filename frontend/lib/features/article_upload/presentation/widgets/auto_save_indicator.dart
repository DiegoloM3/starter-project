import 'package:flutter/material.dart';

class AutoSaveIndicator extends StatelessWidget {
  final DateTime? lastSavedAt;

  const AutoSaveIndicator({super.key, this.lastSavedAt});

  @override
  Widget build(BuildContext context) {
    if (lastSavedAt == null) return const SizedBox.shrink();
    final elapsed = DateTime.now().difference(lastSavedAt!).inSeconds;
    return Text(
      'Draft saved ${elapsed}s ago',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
    );
  }
}
