import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/surfaces/glass_bar.dart';

/// One destination of the tab bar.
class GlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const GlassNavItem({required this.icon, required this.activeIcon, required this.label});
}

/// The app's tab bar: four equal columns on frosted glass, a red bar along
/// the top of the active one, small-capital labels under the icons.
class GlassNavBar extends StatelessWidget {
  final List<GlassNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const GlassNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return GlassBar(
      child: SizedBox(
        height: AppSizes.bottomBar + bottomInset,
        child: Row(
          children: [
            for (final (index, item) in items.indexed)
              Expanded(
                child: _Destination(
                  item: item,
                  selected: index == selectedIndex,
                  bottomInset: bottomInset,
                  onTap: () => onSelected(index),
                  ink: palette.ink,
                  muted: palette.inkSecondary,
                  indicator: palette.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Destination extends StatelessWidget {
  final GlassNavItem item;
  final bool selected;
  final double bottomInset;
  final VoidCallback onTap;
  final Color ink;
  final Color muted;
  final Color indicator;

  const _Destination({
    required this.item,
    required this.selected,
    required this.bottomInset,
    required this.onTap,
    required this.ink,
    required this.muted,
    required this.indicator,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? ink : muted;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: selected ? AppRules.indicator : 0,
                color: indicator,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.md, bottom: bottomInset),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(selected ? item.activeIcon : item.icon, size: 22, color: color),
                  const SizedBox(height: 6),
                  Text(item.label.toUpperCase(), style: AppTypography.navLabel.copyWith(color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
