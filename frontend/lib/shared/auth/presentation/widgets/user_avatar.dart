import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? name;
  final double radius;

  const UserAvatar({
    super.key,
    this.photoUrl,
    this.name,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = name?.trim() ?? '';
    final hasName = trimmed.isNotEmpty;
    final fallback = CircleAvatar(
      radius: radius,
      child: hasName
          ? Text(
              trimmed.characters.first.toUpperCase(),
              style: TextStyle(fontSize: radius * 0.9),
            )
          : Icon(Icons.person, size: radius * 1.2),
    );
    if (photoUrl == null || photoUrl!.isEmpty) return fallback;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}
