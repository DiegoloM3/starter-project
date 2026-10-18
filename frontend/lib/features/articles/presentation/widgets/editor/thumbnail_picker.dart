import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../article_thumbnail.dart';
import 'field_error_text.dart';

/// Shows the chosen thumbnail, or the current one when editing, and lets the journalist change it.
class ThumbnailPicker extends StatelessWidget {
  final Uint8List? pickedImage;
  final String? currentImageURL;
  final VoidCallback onTap;
  final String? errorText;

  const ThumbnailPicker({super.key, required this.onTap, this.pickedImage, this.currentImageURL, this.errorText});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = errorText == null ? colorScheme.outline : colorScheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(border: Border.all(color: borderColor)),
            child: AspectRatio(aspectRatio: 16 / 9, child: _buildPreview()),
          ),
        ),
        if (errorText != null) FieldErrorText(errorText!),
      ],
    );
  }

  Widget _buildPreview() {
    if (pickedImage != null) return Image.memory(pickedImage!, fit: BoxFit.cover);
    if (currentImageURL != null) return ArticleThumbnail(imageURL: currentImageURL!);
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 36),
        SizedBox(height: 8),
        Text('Añadir imagen de portada'),
      ],
    );
  }
}
