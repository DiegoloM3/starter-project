import 'package:flutter/material.dart';

class ArticleImage extends StatelessWidget {
  final String imageUrl;

  const ArticleImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 250,
      margin: const EdgeInsets.only(top: 14),
      child: Image.network(imageUrl, fit: BoxFit.cover),
    );
  }
}
