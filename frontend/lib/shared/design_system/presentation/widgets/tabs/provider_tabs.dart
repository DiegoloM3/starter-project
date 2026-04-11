import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';

class ProviderTabItem {
  final String label;
  final IconData icon;

  const ProviderTabItem({required this.label, required this.icon});
}

class ProviderTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final List<ProviderTabItem> items;

  const ProviderTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: AppDimensions.tabsHeight,
      padding: const EdgeInsets.all(AppDimensions.spacing4),
      decoration: BoxDecoration(
        color: colors.bgCard,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: AppDimensions.spacing4),
            Expanded(child: _buildTab(i, colors)),
          ],
        ],
      ),
    );
  }

  Widget _buildTab(int index, AppColorsExtension colors) {
    final isSelected = index == selectedIndex;
    final item = items[index];
    const int animationDurationMillis = 200;

    return Semantics(
      selected: isSelected,
      button: true,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTabChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: animationDurationMillis),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: AppDimensions.spacing16,
                  color: isSelected ? AppColors.white : colors.textPlaceholder,
                ),
                const SizedBox(width: AppDimensions.spacing8),
                Text(
                  item.label,
                  style: AppTypography.pillLabel.copyWith(
                    color:
                        isSelected ? AppColors.white : colors.textPlaceholder,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
