import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';

/// Profile photo of the user, or their initials when they have none.
class UserAvatar extends StatelessWidget {
  final UserEntity user;
  final double radius;

  const UserAvatar({super.key, required this.user, this.radius = 40});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final photoURL = user.photoURL;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      backgroundImage: photoURL == null ? null : CachedNetworkImageProvider(photoURL),
      child:
          photoURL == null
              ? Text(_initials, style: TextStyle(fontSize: radius * 0.7, fontWeight: FontWeight.w700))
              : null,
    );
  }

  String get _initials =>
      [user.firstName, user.lastName].where((name) => name.isNotEmpty).map((name) => name[0].toUpperCase()).join();
}
