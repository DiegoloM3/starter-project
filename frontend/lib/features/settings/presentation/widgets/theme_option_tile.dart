import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';

/// One choice of a list where only one option can be selected (radio button).
class ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  final bool isSelected;
  final VoidCallback onSelected;

  const ThemeOptionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.detail,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: isSelected,
      child: InkWell(
        onTap: onSelected,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: palette.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: palette.primary),
              ),
              const SizedBox(width: 14),
              Expanded(child: _buildTexts(palette)),
              _SelectionIndicator(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTexts(AppPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(detail, style: TextStyle(fontSize: 13, color: palette.textSecondary)),
      ],
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool isSelected;

  const _SelectionIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? palette.primary : Colors.transparent,
        border: isSelected ? null : Border.all(color: palette.icon, width: 2),
      ),
      child: isSelected ? Icon(Icons.check_rounded, size: 16, color: palette.onPrimary) : null,
    );
  }
}
