import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'app_themes.dart';

/// Bookmark that shows whether an article is saved: empty when it is not, filled in blue when it is.
/// Tapping it saves or removes the article; it is disabled while that is in progress.
class BookmarkButton extends StatelessWidget {
  final bool isSaved;
  final VoidCallback? onPressed;
  final double size;

  const BookmarkButton({super.key, required this.isSaved, required this.onPressed, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IconButton(
      onPressed: onPressed,
      tooltip: isSaved ? 'Remove from saved' : 'Save article',
      isSelected: isSaved,
      color: palette.textPrimary,
      selectedIcon: Icon(Ionicons.bookmark, size: size, color: palette.primary),
      icon: Icon(Ionicons.bookmarkOutline, size: size),
    );
  }
}
