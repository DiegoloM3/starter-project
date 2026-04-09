import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ArticleImage extends StatelessWidget {
  final String? imageUrl;

  const ArticleImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 250,
      margin: const EdgeInsets.only(top: 14),
      child: _buildImageContent(),
    );
  }

  Widget _buildImageContent() {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return _placeholder();
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: const Color(0xFFEEEEEE),
        alignment: Alignment.center,
        child: const CupertinoActivityIndicator(),
      ),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFEEEEEE),
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        size: 40,
        color: Color(0xFF9E9E9E),
      ),
    );
  }
}
