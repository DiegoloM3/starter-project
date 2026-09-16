import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/initials_formatter.dart';

/// Square avatar: the photo when available, otherwise initials. The signed-in
/// user is set in ink with paper initials; other authors on the surface tone.
class UserAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double size;
  final bool isCurrentUser;

  /// Frames the avatar with the 2px ink rule (Home header, Profile).
  final bool ringed;

  const UserAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.size = 44,
    this.isCurrentUser = false,
    this.ringed = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    final Widget avatar = hasPhoto
        ? CachedNetworkImage(
            imageUrl: photoUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorWidget: (_, _, _) => _Initials(name: name, size: size, isCurrentUser: isCurrentUser),
          )
        : _Initials(name: name, size: size, isCurrentUser: isCurrentUser);

    if (!ringed) return SizedBox(width: size, height: size, child: avatar);

    return Container(
      width: size + 8,
      height: size + 8,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: palette.background,
        border: Border.all(color: palette.ink, width: AppRules.strong),
      ),
      child: avatar,
    );
  }
}

class _Initials extends StatelessWidget {
  final String name;
  final double size;
  final bool isCurrentUser;

  const _Initials({required this.name, required this.size, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: isCurrentUser ? palette.accent : palette.surface),
      alignment: Alignment.center,
      child: Text(
        InitialsFormatter.of(name),
        style: AppTypography.glyph(size * 0.34, weight: FontWeight.w800)
            .copyWith(color: isCurrentUser ? palette.onAccent : palette.ink, letterSpacing: size * 0.02),
      ),
    );
  }
}
