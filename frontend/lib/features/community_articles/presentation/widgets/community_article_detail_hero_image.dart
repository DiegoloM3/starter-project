import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/emulator_image_url.dart';

class CommunityArticleDetailHeroImage extends StatelessWidget {
  final String imageUrl;

  const CommunityArticleDetailHeroImage({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: rewriteEmulatorImageUrl(imageUrl),
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        height: 240,
        color: const Color(0xFFEEEEEE),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
      errorWidget: (_, __, ___) => Container(
        height: 240,
        color: const Color(0xFFEEEEEE),
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          size: 40,
          color: Color(0xFF9E9E9E),
        ),
      ),
    );
  }
}
