import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shows how long ago an article was published (e.g. "2 hours ago"), or
/// its date when it was published more than a week ago.
class PublicationDateText extends StatelessWidget {
  final DateTime publicationDate;
  final TextStyle? style;

  const PublicationDateText({Key? key, required this.publicationDate, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      describeTimeSince(publicationDate, DateTime.now()),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }

  static String describeTimeSince(DateTime publicationDate, DateTime now) {
    final elapsedTime = now.difference(publicationDate);
    if (elapsedTime.inMinutes < 1) {
      return 'Just now';
    }
    if (elapsedTime.inHours < 1) {
      return _describeAmountAgo(elapsedTime.inMinutes, 'minute');
    }
    if (elapsedTime.inDays < 1) {
      return _describeAmountAgo(elapsedTime.inHours, 'hour');
    }
    if (elapsedTime.inDays < 7) {
      return _describeAmountAgo(elapsedTime.inDays, 'day');
    }
    return DateFormat.yMMMd().format(publicationDate.toLocal());
  }

  static String _describeAmountAgo(int amount, String unit) {
    return amount == 1 ? '1 $unit ago' : '$amount ${unit}s ago';
  }
}
