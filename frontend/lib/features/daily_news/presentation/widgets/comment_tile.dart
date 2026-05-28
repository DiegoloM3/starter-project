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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              (comment.authorName ?? 'U')[0].toUpperCase(),
              style: AppTypography.sans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
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
                      style: AppTypography.sans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.t1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(comment.createdAt),
                      style: AppTypography.sans(fontSize: 11, color: AppColors.t3),
                    ),
                    if (isOwner) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: onDelete,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.delete_outline,
                              size: 14, color: AppColors.t3),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content ?? '',
                  style: AppTypography.sans(
                    fontSize: 13.5,
                    color: AppColors.t1,
                    height: 1.55,
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
