import 'package:flutter/material.dart';

class ArticleTileImageFrame extends StatelessWidget {
  final Widget child;

  const ArticleTileImageFrame({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: MediaQuery.of(context).size.width / 3,
          height: double.maxFinite,
          color: Colors.black.withOpacity(0.08),
          child: child,
        ),
      ),
    );
  }
}
