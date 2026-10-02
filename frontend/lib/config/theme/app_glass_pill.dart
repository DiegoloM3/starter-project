import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_themes.dart';

/// Translucent "glass" pill that floats above the content, as the navigation bar of the design.
class AppGlassPill extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const AppGlassPill({super.key, required this.height, required this.padding, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final shape = BorderRadius.circular(height / 2);
    return DecoratedBox(
      // The shadow is drawn outside the clipped glass, so the pill looks like it floats.
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [
          BoxShadow(color: palette.navigationShadow, blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.navigationBar,
              borderRadius: shape,
              border: Border.all(color: palette.navigationBorder),
            ),
            child: SizedBox(height: height, child: Padding(padding: padding, child: child)),
          ),
        ),
      ),
    );
  }
}
