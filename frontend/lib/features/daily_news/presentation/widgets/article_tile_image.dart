import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'article_tile_image_frame.dart';

class ArticleTileImage extends StatelessWidget {
  final String imageUrl;

  const ArticleTileImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => ArticleTileImageFrame(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.08),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
      ),
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          const ArticleTileImageFrame(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      errorWidget: (context, url, error) => const ArticleTileImageFrame(
        child: Center(child: Icon(Icons.error)),
      ),
    );
  }
}
