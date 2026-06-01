import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/l10n/app_localizations.dart';

class TortuFeedSlider extends StatefulWidget {
  final VoidCallback onComplete;

  const TortuFeedSlider({super.key, required this.onComplete});

  @override
  State<TortuFeedSlider> createState() => _TortuFeedSliderState();
}

class _TortuFeedSliderState extends State<TortuFeedSlider>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  bool _completed = false;
  late AnimationController _springController;
  late Animation<double> _springAnim;

  static const double _trackHeight = 48.0;
  static const double _thumbSize = 40.0;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _springAnim = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _springController, curve: Curves.elasticOut),
    );
    _springAnim.addListener(() {
      if (mounted) setState(() => _progress = _springAnim.value.clamp(0.0, 1.0));
    });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double trackWidth) {
    if (_completed || !mounted) return;
    setState(() {
      _progress =
          (_progress + details.delta.dx / trackWidth).clamp(0.0, 1.0);
    });
    if (_progress >= 1.0 && !_completed) {
      _completed = true;
      widget.onComplete();
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_completed || !mounted) return;
    if (_progress < 1.0) {
      _springAnim = Tween<double>(begin: _progress, end: 0.0).animate(
        CurvedAnimation(
            parent: _springController, curve: Curves.elasticOut),
      );
      _springController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;

        return GestureDetector(
          onHorizontalDragUpdate: (d) => _onDragUpdate(d, trackWidth),
          onHorizontalDragEnd: _onDragEnd,
          child: SizedBox(
            height: _trackHeight,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Track background
                Container(
                  width: trackWidth,
                  height: _trackHeight,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
                // Fill
                FractionallySizedBox(
                  widthFactor: _progress,
                  child: Opacity(
                    opacity: _progress.clamp(0.0, 1.0),
                    child: Container(
                      height: _trackHeight,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                    ),
                  ),
                ),
                // Label
                if (_progress < 0.5)
                  Center(
                    child: Text(
                      AppLocalizations.of(context).tortuFeedSlideHint,
                      style: AppTypography.bodySm
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                // Thumb
                Positioned(
                  left: _progress * (trackWidth - _thumbSize),
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
