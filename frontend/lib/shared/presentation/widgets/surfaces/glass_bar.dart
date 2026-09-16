import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';

/// Frosted strip that floats over scrolling content: heavy blur, a translucent
/// paper fill and the 2px ink rule along its top edge. Used by the tab bar and
/// the Reader's action bar.
class GlassBar extends StatelessWidget {
  final Widget child;

  const GlassBar({super.key, required this.child});

  static const double blur = 22;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.glass,
            border: Border(top: BorderSide(color: palette.ink, width: AppRules.strong)),
          ),
          child: child,
        ),
      ),
    );
  }
}
