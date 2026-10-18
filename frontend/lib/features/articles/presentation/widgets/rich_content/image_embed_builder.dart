import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Shows the images embedded in the article content.
class ImageEmbedBuilder extends EmbedBuilder {
  const ImageEmbedBuilder();

  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final imageURL = embedContext.node.value.data as String;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: CachedNetworkImage(
        imageUrl: imageURL,
        fit: BoxFit.fitWidth,
        placeholder:
            (_, _) => const AspectRatio(aspectRatio: 16 / 9, child: Center(child: CircularProgressIndicator())),
        errorWidget: (_, _, _) => const Icon(Icons.broken_image_outlined),
      ),
    );
  }
}
