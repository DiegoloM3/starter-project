import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class TortuTipTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTap;
  final bool isWriter;

  const TortuTipTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabTap,
    this.isWriter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.huge * 2, 0, AppSpacing.huge * 2, AppSpacing.xxxl,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.huge,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: [
            BoxShadow(
              color: AppColors.dark.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TabIcon(
              icon: Icons.article_outlined,
              selectedIcon: Icons.article,
              selected: currentIndex == 0,
              onTap: () => onTabTap(0),
            ),
            if (isWriter) ...[
              const SizedBox(width: AppSpacing.sm),
              _TabIconCenter(onTap: () => onTabTap(1)),
              const SizedBox(width: AppSpacing.sm),
            ] else
              const SizedBox(width: AppSpacing.sm),
            _TabIcon(
              icon: Icons.explore_outlined,
              selectedIcon: Icons.explore,
              selected: currentIndex == 2,
              onTap: () => onTabTap(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabIcon extends StatefulWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  const _TabIcon({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_TabIcon> createState() => _TabIconState();
}

class _TabIconState extends State<_TabIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.82,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.reverse();
  void _onTapUp(_) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: const BoxDecoration(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              widget.selected ? widget.selectedIcon : widget.icon,
              key: ValueKey(widget.selected),
              color: widget.selected
                  ? AppColors.textOnDark
                  : AppColors.textOnDark.withValues(alpha: 0.45),
              size: AppSpacing.iconTabBar,
            ),
          ),
        ),
      ),
    );
  }
}

class _TabIconCenter extends StatefulWidget {
  final VoidCallback onTap;
  const _TabIconCenter({required this.onTap});

  @override
  State<_TabIconCenter> createState() => _TabIconCenterState();
}

class _TabIconCenterState extends State<_TabIconCenter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 250),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.reverse();
  void _onTapCancel() => _controller.forward();

  Future<void> _onTap() async {
    await _controller.animateTo(_controller.lowerBound);
    await _controller.forward();
    if (mounted) widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      onTapDown: _onTapDown,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
          reverseCurve: Curves.elasticOut,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: const Icon(
            Icons.edit_outlined,
            color: AppColors.textOnDark,
            size: AppSpacing.iconTabBar,
          ),
        ),
      ),
    );
  }
}
