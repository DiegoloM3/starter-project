import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class TortuProgressDots extends StatelessWidget {
  final int total;
  final int current; // 0-indexed

  const TortuProgressDots({
    super.key,
    required this.total,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 32 : 20,
          height: 4,
          decoration: BoxDecoration(
            color: isActive ? AppColors.textPrimary : AppColors.borderStrong,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
