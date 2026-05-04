import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

class ThumbnailPicker extends StatelessWidget {
  final String? localImagePath;
  final Uint8List? compressedBytes;
  final String? existingRemoteUrl;
  final bool isPicking;
  final VoidCallback onPickFromGallery;
  final VoidCallback onPickFromCamera;
  final VoidCallback? onClear;

  const ThumbnailPicker({
    super.key,
    this.localImagePath,
    this.compressedBytes,
    this.existingRemoteUrl,
    required this.isPicking,
    required this.onPickFromGallery,
    required this.onPickFromCamera,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          _buildContent(context),
          if (isPicking)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (compressedBytes != null) {
      return _FilledThumbnail(
        image: Image.memory(compressedBytes!, fit: BoxFit.cover),
        onClear: onClear,
      );
    }
    if (existingRemoteUrl != null && existingRemoteUrl!.isNotEmpty) {
      return _FilledThumbnail(
        image: Image.network(existingRemoteUrl!, fit: BoxFit.cover),
        onReplaceFromGallery: onPickFromGallery,
        onReplaceFromCamera: onPickFromCamera,
      );
    }
    return _EmptyThumbnail(
      onGallery: onPickFromGallery,
      onCamera: onPickFromCamera,
    );
  }
}

class _EmptyThumbnail extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  const _EmptyThumbnail({required this.onGallery, required this.onCamera});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined, size: 40),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context).thumbnailPickerTitle),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: onGallery,
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: Text(AppLocalizations.of(context).thumbnailFromGallery),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onCamera,
                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                label: Text(AppLocalizations.of(context).thumbnailFromCamera),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilledThumbnail extends StatelessWidget {
  final Image image;
  final VoidCallback? onClear;
  final VoidCallback? onReplaceFromGallery;
  final VoidCallback? onReplaceFromCamera;

  const _FilledThumbnail({
    required this.image,
    this.onClear,
    this.onReplaceFromGallery,
    this.onReplaceFromCamera,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          if (onClear != null)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                onPressed: onClear,
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          if (onReplaceFromGallery != null && onReplaceFromCamera != null)
            Positioned(
              bottom: 8,
              right: 8,
              child: Row(
                children: [
                  IconButton.filled(
                    onPressed: onReplaceFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    tooltip: 'Replace from Gallery',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton.filled(
                    onPressed: onReplaceFromCamera,
                    icon: const Icon(Icons.camera_alt_outlined),
                    tooltip: 'Replace from Camera',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
