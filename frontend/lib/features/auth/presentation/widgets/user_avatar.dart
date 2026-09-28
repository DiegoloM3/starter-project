import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';

/// Shared user avatar: photo when available, initial letter otherwise.
///
/// Pure presentation: takes a [UserEntity] via constructor, owns no bloc,
/// performs no navigation, and touches no data layer (3.4.1/3.4.2).
class UserAvatar extends StatelessWidget {
  final UserEntity? user;
  final bool isLoggedIn;
  final double radius;
  final Color photoBackground;
  final Color fallbackBackground;
  final TextStyle? fallbackTextStyle;
  final String loggedOutLetter;

  const UserAvatar({
    super.key,
    this.user,
    this.isLoggedIn = false,
    this.radius = 15,
    this.photoBackground = Colors.black87,
    this.fallbackBackground = Colors.black12,
    this.fallbackTextStyle,
    this.loggedOutLetter = '?',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn && user?.photoUrl?.isNotEmpty == true) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: photoBackground,
        backgroundImage: CachedNetworkImageProvider(user!.photoUrl!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: isLoggedIn ? photoBackground : fallbackBackground,
      child: Text(
        _letter(),
        style: fallbackTextStyle ??
            TextStyle(
              fontSize: radius * 0.8,
              fontWeight: FontWeight.bold,
              color: isLoggedIn ? Colors.white : Colors.black54,
            ),
      ),
    );
  }

  String _letter() {
    if (!isLoggedIn || user == null) return loggedOutLetter;
    if (user!.displayName?.isNotEmpty == true) {
      return user!.displayName![0].toUpperCase();
    }
    if (user!.email.isNotEmpty) return user!.email[0].toUpperCase();
    return 'U';
  }
}
