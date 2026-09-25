import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum AppToastType { success, error }

/// Replaces the default Material SnackBar across the app. Anchored at the
/// bottom, like a conventional snackbar. Inserted straight into the
/// Overlay instead of going through ScaffoldMessenger, so its look isn't
/// constrained by SnackBar's own defaults.
class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.success,
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AppToastBanner(
        message: message,
        type: type,
        onDismissed: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _AppToastBanner extends StatefulWidget {
  final String message;
  final AppToastType type;
  final VoidCallback onDismissed;

  const _AppToastBanner({
    required this.message,
    required this.type,
    required this.onDismissed,
  });

  @override
  State<_AppToastBanner> createState() => _AppToastBannerState();
}

class _AppToastBannerState extends State<_AppToastBanner> {
  static const _visibleFor = Duration(milliseconds: 2600);
  static const _exitDuration = Duration(milliseconds: 250);

  bool _visible = true;

  @override
  void initState() {
    super.initState();
    // Driven by our own timers, not flutter_animate's onComplete callback --
    // onComplete only fires on AnimationStatus.completed (the forward run),
    // never on the reverse (dismissed), so it can't reliably tell us when
    // the exit animation has actually finished.
    Future.delayed(_visibleFor, () {
      if (mounted) setState(() => _visible = false);
    });
    Future.delayed(_visibleFor + _exitDuration, widget.onDismissed);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSuccess = widget.type == AppToastType.success;
    // Success/error stay fixed green/red in both modes -- semantic colors,
    // not brand colors, so they deliberately don't come from colorScheme.
    final accent =
        isSuccess ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final icon = isSuccess ? Icons.check_circle_rounded : Icons.error_rounded;

    return Positioned(
      // Clears MainShell's floating tab bar (~68px tall) on the tab screens.
      bottom: MediaQuery.of(context).padding.bottom + 88,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border(left: BorderSide(color: accent, width: 4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(target: _visible ? 1 : 0)
        .fadeIn(duration: 250.ms, curve: Curves.easeOut)
        .slideY(begin: 0.3, end: 0, duration: 350.ms, curve: Curves.easeOutBack);
  }
}
