import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';

/// The "Add Thumbnail" component of the design, with two states:
/// an "Attach Image" button, or the picked image at full width (tap it to change it).
class AddThumbnail extends StatelessWidget {
  final String? imagePath;

  /// Opens the gallery. `null` disables the component (e.g. while publishing).
  final VoidCallback? onPickImage;
  final String? errorText;

  const AddThumbnail({super.key, this.imagePath, this.onPickImage, this.errorText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentState(),
        ),
        if (errorText != null) _buildErrorText(context),
      ],
    );
  }

  Widget _buildCurrentState() {
    final imagePath = this.imagePath;
    if (imagePath == null) {
      return _AttachImageButton(key: const ValueKey('attach-image'), onPressed: onPickImage);
    }
    return _ThumbnailPreview(key: ValueKey(imagePath), imagePath: imagePath, onTap: onPickImage);
  }

  Widget _buildErrorText(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(
        errorText!,
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.error, fontSize: 13),
      ),
    );
  }
}

class _AttachImageButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _AttachImageButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: Text(context.l10n.attachImage),
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ThumbnailPreview extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onTap;

  const _ThumbnailPreview({super.key, required this.imagePath, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.articleImageHint,
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(File(imagePath), fit: BoxFit.cover, errorBuilder: _buildBrokenImage),
              const Positioned(right: 12, bottom: 12, child: _ChangeImageChip()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrokenImage(BuildContext context, Object error, StackTrace? stackTrace) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.broken_image_outlined, size: 48),
    );
  }
}

class _ChangeImageChip extends StatelessWidget {
  const _ChangeImageChip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_library_outlined, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              context.l10n.changeImage,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
