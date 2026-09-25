import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'brand_mark.dart';

/// A full-screen overlay covering the entire submit: the app's mark
/// drawing itself for as long as the save genuinely takes, becoming a
/// checkmark the moment it actually succeeds -- one continuous piece of
/// feedback instead of a small button spinner followed by a separate
/// celebration shown only once the wait is already over.
class SubmitProgressOverlay {
  OverlayEntry? _entry;
  final _succeeded = ValueNotifier<bool>(false);

  /// Inserts the overlay, showing the mark drawing itself on a loop. A
  /// second call while already showing is a no-op, so a listener that
  /// fires more than once for the same submit can't insert it twice.
  void showLoading(BuildContext context) {
    if (_entry != null) return;
    _succeeded.value = false;
    final entry = OverlayEntry(
      builder: (_) => _SubmitOverlayWidget(succeeded: _succeeded),
    );
    _entry = entry;
    Overlay.of(context).insert(entry);
  }

  /// Switches the same overlay to the checkmark, holds it briefly, then
  /// removes it. The Future completes once it's gone, so a caller can
  /// chain a navigation pop after it.
  Future<void> showSuccess() async {
    if (_entry == null) return;
    _succeeded.value = true;
    await Future.delayed(const Duration(milliseconds: 700));
    dismiss();
  }

  /// Removes the overlay without a checkmark -- the submit failed.
  void dismiss() {
    _entry?.remove();
    _entry = null;
  }
}

class _SubmitOverlayWidget extends StatelessWidget {
  final ValueNotifier<bool> succeeded;

  const _SubmitOverlayWidget({required this.succeeded});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned.fill(
      key: const Key('submitProgressOverlay'),
      child: IgnorePointer(
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.6),
          child: Center(
            child: ValueListenableBuilder<bool>(
              valueListenable: succeeded,
              builder: (context, isSuccess, _) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isSuccess
                    ? _CheckMark(
                        key: const ValueKey('check'), colorScheme: colorScheme)
                    : const KeyedSubtree(
                        key: ValueKey('loading'),
                        child: AnimatedBrandMark(size: 72),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckMark extends StatelessWidget {
  final ColorScheme colorScheme;

  const _CheckMark({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
    )
        .animate()
        .scale(
          begin: const Offset(0.4, 0.4),
          end: const Offset(1, 1),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 200.ms);
  }
}
