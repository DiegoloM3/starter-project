import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../extensions/build_context_extensions.dart';
import '../previews/app_preview.dart';

/// Bottom sheet modal asking the user to confirm article deletion.
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (_) => DeleteConfirmationSheet(onDelete: () { ... }),
/// );
/// ```
class DeleteConfirmationSheet extends StatelessWidget {
  const DeleteConfirmationSheet({
    required this.onDelete,
    super.key,
    this.onCancel,
  });

  final VoidCallback onDelete;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Delete article?', style: context.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'This action cannot be undone.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          // DELETE button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              icon: const Icon(Ionicons.trash_outline, size: 18),
              label: const Text('DELETE'),
            ),
          ),
          const SizedBox(height: 12),
          // CANCEL button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                onCancel?.call();
              },
              child: const Text('CANCEL'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Preview of delete confirmation sheet.
@AppPreview(name: 'Delete Confirmation Sheet')
Widget previewDeleteConfirmationSheet() {
  return Material(
    child: DeleteConfirmationSheet(onDelete: () {}, onCancel: () {}),
  );
}
