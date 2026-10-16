import 'dart:io';

import 'package:flutter/material.dart';

/// Full width preview of the picked thumbnail. Tapping it lets the user pick
/// another image.
class ArticleThumbnailPreview extends StatelessWidget {
  static const double height = 225;

  final String imagePath;
  final VoidCallback onTap;

  const ArticleThumbnailPreview({Key? key, required this.imagePath, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Change image',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: Color(0x14000000),
              child: Center(child: Icon(Icons.broken_image_outlined)),
            ),
          ),
        ),
      ),
    );
  }
}
