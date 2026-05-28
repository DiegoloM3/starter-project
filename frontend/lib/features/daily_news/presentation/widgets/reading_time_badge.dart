import 'package:flutter/material.dart';

class ReadingTimeBadge extends StatelessWidget {
  final int minutes;

  const ReadingTimeBadge({Key? key, required this.minutes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.schedule,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 3),
        Text(
          '$minutes min read',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
