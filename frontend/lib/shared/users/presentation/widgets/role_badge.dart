import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';

/// Outlined label with the role, e.g. "PERIODISTA".
class RoleBadge extends StatelessWidget {
  final UserRole role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.outline)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          _label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
      ),
    );
  }

  String get _label => switch (role) {
    UserRole.journalist => 'Periodista',
    UserRole.reader => 'Lector',
  };
}
