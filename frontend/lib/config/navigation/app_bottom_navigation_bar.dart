import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_glass_pill.dart';
import '../theme/app_themes.dart';

enum AppSection { home, saved, profile, settings }

/// Translucent "glass" pill floating above the content: Home · Saved · + · Profile · Settings.
class AppBottomNavigationBar extends StatelessWidget {
  static const double height = 64;
  static const double _sideMargin = 16;
  static const double _minimumBottomMargin = 12;

  final AppSection currentSection;
  final ValueChanged<AppSection> onSectionSelected;
  final VoidCallback onCreatePressed;

  const AppBottomNavigationBar({
    super.key,
    required this.currentSection,
    required this.onSectionSelected,
    required this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context) {
    // Rests right on top of the area the phone keeps for its gesture bar (its swipes must not
    // reach the buttons), and never closer than 12 px to the bottom edge.
    final bottomMargin = math.max(MediaQuery.paddingOf(context).bottom, _minimumBottomMargin);
    return Padding(
      padding: EdgeInsets.only(bottom: bottomMargin),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _sideMargin),
        child: AppGlassPill(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: _buildButtons(),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionButton(AppSection.home, Icons.home_outlined, Icons.home_rounded, 'Home'),
        _buildSectionButton(AppSection.saved, Icons.bookmark_border_rounded, Icons.bookmark_rounded, 'Saved articles'),
        _CreateButton(onPressed: onCreatePressed),
        _buildSectionButton(AppSection.profile, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
        _buildSectionButton(AppSection.settings, Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
      ],
    );
  }

  Widget _buildSectionButton(AppSection section, IconData icon, IconData selectedIcon, String label) {
    return _SectionButton(
      icon: icon,
      selectedIcon: selectedIcon,
      label: label,
      isSelected: section == currentSection,
      onPressed: () => onSectionSelected(section),
    );
  }
}

class _SectionButton extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _SectionButton({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = isSelected ? palette.primary : palette.icon;
    return Semantics(
      selected: isSelected,
      child: IconButton(
        onPressed: onPressed,
        tooltip: label,
        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
        icon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? selectedIcon : icon, size: 24, color: color),
            const SizedBox(height: 3),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? palette.primary : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.primary,
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: 'Publish an article',
        icon: Icon(Icons.add_rounded, color: palette.onPrimary, size: 26),
      ),
    );
  }
}
