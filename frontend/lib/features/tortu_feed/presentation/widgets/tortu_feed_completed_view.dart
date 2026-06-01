import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/l10n/app_localizations.dart';

class TortuFeedCompletedView extends StatefulWidget {
  final VoidCallback onDone;

  const TortuFeedCompletedView({super.key, required this.onDone});

  @override
  State<TortuFeedCompletedView> createState() => _TortuFeedCompletedViewState();
}

class _TortuFeedCompletedViewState extends State<TortuFeedCompletedView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  Timer? _doneTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _controller.forward();
    _doneTimer = Timer(const Duration(seconds: 2), widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    _doneTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: _scaleAnim,
            child: const Text(
              '🐢',
              style: TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).tortuFeedCompleted,
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                AppLocalizations.of(context).tortuFeedHappy,
                style:
                    AppTypography.body.copyWith(color: AppColors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
