import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImagePickerSection extends StatelessWidget {
  /// Local file the user just picked. Wins over [existingImageUrl].
  final File? pickedImage;

  /// URL of the image the article already has (edit mode). Shown only when
  /// no local file has been picked yet.
  final String? existingImageUrl;

  final VoidCallback onPick;
  final VoidCallback onRemove;

  const ImagePickerSection({
    Key? key,
    required this.pickedImage,
    required this.existingImageUrl,
    required this.onPick,
    required this.onRemove,
  }) : super(key: key);

  bool get _hasAnyImage =>
      pickedImage != null ||
      (existingImageUrl != null && existingImageUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    if (!_hasAnyImage) {
      return OutlinedButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.image_outlined),
        label: const Text('Add image (optional)'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: pickedImage != null
              ? Image.file(
                  pickedImage!,
                  height: 200,
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: existingImageUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 200,
                    color: const Color(0xFFEEEEEE),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 200,
                    color: const Color(0xFFEEEEEE),
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined,
                        color: Color(0xFF9E9E9E)),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Replace'),
            ),
            TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove'),
            ),
          ],
        ),
      ],
    );
  }
}
