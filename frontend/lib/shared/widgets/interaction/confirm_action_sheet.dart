import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/global_themes.dart';

class ConfirmActionSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const ConfirmActionSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onCancel,
    required this.onConfirm,
  });


  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    late OverlayEntry entry;
    void close() => entry.remove();

    entry = OverlayEntry(
      builder: (_) => _DimmedOverlay(
        sheet: ConfirmActionSheet(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          confirmColor: confirmColor,
          onCancel: close,
          onConfirm: () {
            close();
            onConfirm();
          },
        ),
      ),
    );

    Overlay.of(context).insert(entry);
  }



  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: _buildSheetDecoration(context),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(context),
              const SizedBox(height: 8),
              _buildMessage(context),
              const SizedBox(height: 20),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildSheetDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: GlobalTheme.kInk, width: 1.5),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(title, style: GlobalTheme.masthead(Theme.of(context).colorScheme, fontSize: 18));
  }

  Widget _buildMessage(BuildContext context) {
    return Text(message, style: Theme.of(context).textTheme.bodyMedium);
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildCancelButton()),
        const SizedBox(width: 12),
        Expanded(child: _buildConfirmButton(context)),
      ],
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton(
      onPressed: onCancel,
      style: OutlinedButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        side: BorderSide(color: GlobalTheme.kRule),
      ),
      child: const Text('Cancelar'),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onConfirm,
      style: ElevatedButton.styleFrom(
        backgroundColor: confirmColor,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: Text(confirmLabel),
    );
  }
}


class _DimmedOverlay extends StatelessWidget {
  final Widget sheet;
  const _DimmedOverlay({required this.sheet});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,   
            onTap:null,                        
            child: Container(color: Colors.black.withValues(alpha: 0.35)),
          ),
        ),
        Align(alignment: Alignment.bottomCenter, child: sheet),
      ],
    );
  }
}