import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../config/theme/app_themes.dart';
import '../../domain/entities/comment.dart';

class CommentTile extends StatelessWidget {
  final CommentEntity comment;
  final bool isOwner;
  final VoidCallback? onDelete;

  const CommentTile({
    Key? key,
    required this.comment,
    this.isOwner = false,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              (comment.authorName ?? 'U')[0].toUpperCase(),
              style: tt.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName ??
                          AppLocalizations.of(context)!.unknownAuthor,
                      style: tt.bodySmall?.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(comment.createdAt),
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: cs.outlineVariant,
                        letterSpacing: 0,
                      ),
                    ),
                    if (isOwner) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: onDelete,
                        child: Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.xs),
                          child: Icon(Icons.delete_outline,
                              size: 14, color: cs.outlineVariant),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  comment.content ?? '',
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: cs.onSurface,
                    height: 1.55,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
