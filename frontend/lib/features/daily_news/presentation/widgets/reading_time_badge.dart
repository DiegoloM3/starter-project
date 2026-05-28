import 'package:flutter/material.dart';

import '../../../../config/theme/app_themes.dart';

class ReadingTimeBadge extends StatelessWidget {
  final int minutes;

  const ReadingTimeBadge({Key? key, required this.minutes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.schedule, size: 12, color: AppColors.t3),
        const SizedBox(width: 3),
        Text(
          '$minutes min read',
          style: AppTypography.sans(fontSize: 11, color: AppColors.t3),
        ),
      ],
    );
  }
}
