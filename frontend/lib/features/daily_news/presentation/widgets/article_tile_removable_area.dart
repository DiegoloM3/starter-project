import 'package:flutter/material.dart';

class ArticleTileRemovableArea extends StatelessWidget {
  final bool isRemovable;
  final VoidCallback onRemove;

  const ArticleTileRemovableArea({
    Key? key,
    required this.isRemovable,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isRemovable) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onRemove,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.remove_circle_outline, color: Colors.red),
      ),
    );
  }
}
