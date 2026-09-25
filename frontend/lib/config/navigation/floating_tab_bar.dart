import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

typedef _TabSpec = ({
  IconData icon,
  IconData selectedIcon,
  String Function(AppLocalizations l10n) label,
});

/// A floating, frosted-glass pill tab bar -- the current iOS "Liquid Glass"
/// look, not the classic edge-to-edge Material BottomNavigationBar. Used as
/// Scaffold's `bottomNavigationBar` (not a manually Positioned overlay), so
/// Flutter reserves space for it automatically and no screen's list content
/// ends up hidden behind it. "+" sits in the middle as a filled circle, so
/// the one action stands apart from the four places to go around it.
class FloatingTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onCreatePressed;

  const FloatingTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onCreatePressed,
  });

  static final _tabs = <_TabSpec>[
    (icon: Icons.newspaper_outlined, selectedIcon: Icons.newspaper, label: (l10n) => l10n.tabNews),
    (icon: Icons.article_outlined, selectedIcon: Icons.article, label: (l10n) => l10n.tabMyArticles),
    (icon: Icons.bookmark_outline, selectedIcon: Icons.bookmark, label: (l10n) => l10n.tabSaved),
    (icon: Icons.person_outline, selectedIcon: Icons.person, label: (l10n) => l10n.tabProfile),
  ];

  Widget _tab(int index) {
    return Expanded(
      child: _TabButton(
        tab: _tabs[index],
        selected: index == selectedIndex,
        onTap: () => onTabSelected(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final middle = _tabs.length ~/ 2;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: _GlassSurface(
          color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.72),
          padding: const EdgeInsets.all(6),
          // Every slot gets an equal share of the width, so the bar fits
          // the narrowest phones instead of overflowing.
          child: Row(
            children: [
              for (var i = 0; i < middle; i++) _tab(i),
              Expanded(child: _CreateArticleButton(onPressed: onCreatePressed)),
              for (var i = middle; i < _tabs.length; i++) _tab(i),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final _TabSpec tab;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label(context.l10n),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(
            selected ? tab.selectedIcon : tab.icon,
            color: selected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _CreateArticleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateArticleButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: context.l10n.newArticle,
      child: Tooltip(
        message: context.l10n.newArticle,
        child: GestureDetector(
          onTap: onPressed,
          // heightFactor: 1 keeps Center only as tall as the circle. Without
          // it, Center fills all the height it's offered, and a
          // bottomNavigationBar is offered the whole screen.
          child: Center(
            heightFactor: 1,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: colorScheme.onPrimary,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted glass shared by the pill and the "+" circle (a square child makes
/// the 999 radius a circle).
class _GlassSurface extends StatelessWidget {
  final Color color;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _GlassSurface({
    required this.color,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(999);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
