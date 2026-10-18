import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/comment.dart';

/// One comment. [onDelete] is only given for the comments of the signed in user.
class CommentTile extends StatelessWidget {
  final CommentEntity comment;
  final VoidCallback onAuthorTap;
  final VoidCallback? onDelete;

  const CommentTile({super.key, required this.comment, required this.onAuthorTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onAuthorTap,
                  child: Text(
                    comment.authorName,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat.yMMMd().add_Hm().format(comment.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Text(comment.text, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(tooltip: 'Eliminar comentario', icon: const Icon(Icons.delete_outline), onPressed: onDelete),
        ],
      ),
    );
  }
}
