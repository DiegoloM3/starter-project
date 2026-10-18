import 'package:flutter/material.dart';

/// Filled "SEGUIR" while not following, outlined "SIGUIENDO" once following.
class FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onPressed;

  const FollowButton({super.key, required this.isFollowing, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const minimumSize = Size(160, 44);
    if (isFollowing) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: minimumSize),
        onPressed: onPressed,
        child: const Text('SIGUIENDO'),
      );
    }
    return FilledButton(
      style: FilledButton.styleFrom(minimumSize: minimumSize),
      onPressed: onPressed,
      child: const Text('SEGUIR'),
    );
  }
}
