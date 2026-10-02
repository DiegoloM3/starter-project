import 'package:flutter/material.dart';

import 'app_themes.dart';

/// Circle with the initials of a journalist's name. Large avatars float on a soft shadow.
class UserAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final bool hasShadow;

  const UserAvatar({super.key, required this.initials, this.size = 96, this.hasShadow = true});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.primary,
        shape: BoxShape.circle,
        boxShadow: [
          if (hasShadow)
            BoxShadow(color: palette.primary.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: palette.onPrimary,
          fontSize: size * 0.35,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
