import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_theme_extension.dart';

/// Square tile that previews the selected thumbnail or prompts the user to
/// pick one. Actual picking is delegated to [onPick] so the widget stays
/// platform-agnostic — the DI container wires image_picker in release and
/// a canned picker in tests.
class ThumbnailPickerTile extends StatelessWidget {
  const ThumbnailPickerTile({
    required this.onPick,
    required this.remoteURL,
    this.pendingBytes,
    super.key,
  });

  final VoidCallback onPick;
  final String remoteURL;
  final List<int>? pendingBytes;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final hasPending = pendingBytes != null && pendingBytes!.isNotEmpty;
    final hasRemote = remoteURL.startsWith('http');

    return Semantics(
      label: 'Article thumbnail',
      button: true,
      child: InkWell(
        onTap: onPick,
        borderRadius: theme.radii.mdRadius,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: theme.surfaceMuted,
            borderRadius: theme.radii.mdRadius,
            border: Border.all(color: theme.divider),
          ),
          child: ClipRRect(
            borderRadius: theme.radii.mdRadius,
            child: _buildContent(theme, hasPending: hasPending, hasRemote: hasRemote),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    AppTheme theme, {
    required bool hasPending,
    required bool hasRemote,
  }) {
    if (hasPending) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            Uint8List.fromList(pendingBytes!),
            fit: BoxFit.cover,
          ),
          _overlay('Tap to change'),
        ],
      );
    }
    if (hasRemote) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: remoteURL,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) =>
                _placeholder(theme, 'Tap to pick an image'),
          ),
          _overlay('Tap to change'),
        ],
      );
    }
    return _placeholder(theme, 'Tap to pick a thumbnail');
  }

  Widget _placeholder(AppTheme theme, String text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 40,
          color: theme.onSurfaceMuted,
        ),
        SizedBox(height: theme.spacing.sm),
        Text(
          text,
          style: TextStyle(fontSize: 13, color: theme.onSurfaceMuted),
        ),
      ],
    );
  }

  Widget _overlay(String text) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ColoredBox(
        color: const Color(0x66000000),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}
