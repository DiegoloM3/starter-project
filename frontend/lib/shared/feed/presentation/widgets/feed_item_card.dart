import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/shared/feed/domain/entities/feed_item.dart';
import 'package:news_app_clean_architecture/shared/feed/presentation/widgets/source_badge.dart';

class FeedItemCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback? onTap;

  // Fixed media + content height keeps every row visually identical
  // regardless of title length or whether the author is set.
  static const double _kRowHeight = 96;
  static const double _kThumbnailWidth = 128;

  const FeedItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          height: _kRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: _kThumbnailWidth,
                  child: item.thumbnailUrl.isEmpty
                      ? Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                        )
                      : Image.network(
                          item.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SourceBadge(label: item.sourceLabel),
                        if (item.authorDisplayName != null &&
                            item.authorDisplayName!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              item.authorDisplayName!,
                              style: theme.textTheme.labelSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Always reserves 2 lines of vertical space — short
                    // titles get a blank second line so neighbours line up.
                    SizedBox(
                      height:
                          (theme.textTheme.titleSmall?.fontSize ?? 14) * 2 *
                              (theme.textTheme.titleSmall?.height ?? 1.3),
                      child: Text(
                        item.title,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: theme.textTheme.labelSmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatLocal(item.publishedAt),
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static final _dateFormat = DateFormat('MMM d, y · h:mm a');

  static String _formatLocal(DateTime instant) {
    return _dateFormat.format(instant.toLocal());
  }
}
