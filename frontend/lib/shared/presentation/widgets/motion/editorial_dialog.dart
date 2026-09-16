import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_motion.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';

/// Shows a dialog that settles into place: scale 0.92 → 1 with a fade over
/// 200 ms, under an ink scrim. Replaces Material's plain fade everywhere a
/// confirmation is asked.
Future<T?> showEditorialDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final palette = context.palette;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: palette.ink.withValues(alpha: 0.45),
    transitionDuration: AppMotion.durationFor(context, AppMotion.short),
    pageBuilder: (context, _, _) => builder(context),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}
