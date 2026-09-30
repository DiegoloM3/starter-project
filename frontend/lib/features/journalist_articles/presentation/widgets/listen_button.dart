import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';

/// Big "Listen to this article" / "Stop reading" button for the article screen.
class ListenButton extends StatelessWidget {
  final bool isReading;
  final VoidCallback onPressed;

  const ListenButton({super.key, required this.isReading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(isReading ? Icons.stop_rounded : Icons.volume_up_rounded, key: ValueKey(isReading)),
      ),
      label: Text(isReading ? context.l10n.stopReading : context.l10n.listenToArticle),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
