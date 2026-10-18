import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ArticleThumbnail extends StatelessWidget {
  final String imageURL;
  final double aspectRatio;

  const ArticleThumbnail({super.key, required this.imageURL, this.aspectRatio = 16 / 9});

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: CachedNetworkImage(
        imageUrl: imageURL,
        fit: BoxFit.cover,
        placeholder: (_, _) => ColoredBox(color: placeholderColor),
        errorWidget:
            (_, _, _) => ColoredBox(color: placeholderColor, child: const Icon(Icons.image_not_supported_outlined)),
      ),
    );
  }
}
