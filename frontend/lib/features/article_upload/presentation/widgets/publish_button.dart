import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_app_clean_architecture/config/theme/theme.dart';

class PublishButton extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback? onPressed;

  const PublishButton({
    Key? key,
    required this.isEnabled,
    required this.isLoading,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<Color?>(
          tween: ColorTween(
            begin: AppColors.surfaceBorder,
            end: isEnabled ? AppColors.accent : AppColors.surfaceBorder,
          ),
          duration: const Duration(milliseconds: 200),
          builder: (context, color, child) {
            return SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (isEnabled && !isLoading) ? _onTap : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  disabledBackgroundColor: AppColors.surfaceBorder,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  elevation: 0,
                ),
                child: _buildChild(),
              ),
            );
          },
        ),
        if (isLoading) ...[
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Publishing your article...',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
      );
    }
    return Text(
      'Publish',
      style: AppTextStyles.button.copyWith(
        color: isEnabled ? Colors.black : AppColors.textHint,
      ),
    );
  }

  void _onTap() {
    HapticFeedback.mediumImpact();
    onPressed?.call();
  }
}
