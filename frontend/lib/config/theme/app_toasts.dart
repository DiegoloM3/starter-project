import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:toastification/toastification.dart';

import 'app_themes.dart';

enum AppToastType { success, info, error }

/// A short message that the app shows to the journalist after an action, such as "Article saved".
class AppToast {
  final AppToastType type;
  final String title;
  final String? description;

  const AppToast.success(this.title, {this.description}) : type = AppToastType.success;

  const AppToast.info(this.title, {this.description}) : type = AppToastType.info;

  const AppToast.error(this.title, {this.description}) : type = AppToastType.error;
}

/// Where the toasts appear: at the bottom, floating above the pills of the design (the navigation bar and
/// the comment box), which rest 64 px tall on top of the phone's gesture area. Toastification adds that area
/// and the keyboard to this margin.
final ToastificationConfig appToastificationConfig = ToastificationConfig(
  alignment: Alignment.bottomCenter,
  itemWidth: 560,
  animationDuration: const Duration(milliseconds: 350),
  marginBuilder: (context, alignment) => const EdgeInsets.fromLTRB(16, 0, 16, 76),
);

void showAppToast(BuildContext context, AppToast toast) {
  toastification.showCustom(
    context: context,
    autoCloseDuration: const Duration(seconds: 4),
    builder: (context, item) => AppToastCard(
      toast: toast,
      onClose: () => toastification.dismissById(item.id),
    ),
  );
}

/// The card of a toast: an icon of its type, its texts and a button to close it.
class AppToastCard extends StatelessWidget {
  final AppToast toast;
  final VoidCallback onClose;

  const AppToastCard({super.key, required this.toast, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.divider),
          boxShadow: [
            BoxShadow(color: palette.navigationShadow, blurRadius: 30, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            _ToastIcon(type: toast.type),
            const SizedBox(width: 12),
            Expanded(child: _buildTexts(palette)),
            IconButton(
              onPressed: onClose,
              tooltip: 'Close',
              color: palette.icon,
              icon: const Icon(Ionicons.close, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTexts(AppPalette palette) {
    final description = toast.description;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          toast.title,
          style: TextStyle(fontFamily: 'Muli', fontSize: 14, fontWeight: FontWeight.w800, color: palette.textPrimary),
        ),
        if (description != null) ...[
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(fontFamily: 'Muli', fontSize: 13, height: 1.4, color: palette.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _ToastIcon extends StatelessWidget {
  final AppToastType type;

  const _ToastIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (color, background, icon) = switch (type) {
      AppToastType.success => (palette.success, palette.successSoft, Ionicons.checkmark),
      AppToastType.info => (palette.primary, palette.primarySoft, Ionicons.bookmarkOutline),
      AppToastType.error => (palette.error, palette.errorSoft, Ionicons.alert),
    };
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, size: 18, color: color),
    );
  }
}
