import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/shared/widgets/feedback/press_loading_indicator_widget.dart';

class ArticleItemWidget extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;
  final String dateText;
  final VoidCallback? onTap;

  const ArticleItemWidget({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.dateText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.only(start: 14, end: 14, bottom: 7, top: 7),
        height: MediaQuery.of(context).size.width / 2.2,
        child: Row(
          children: [
            _buildImage(context),
            _buildTitleAndDescription(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      progressIndicatorBuilder: (context, url, downloadProgress) => _buildImageFrame(
        context,
        child: Center(
          child: PressLoadingIndicatorWidget(
            color: Theme.of(context).colorScheme.secondary,
            size: 6,
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildImageFrame(
        context,
        child: const Icon(Icons.error),
      ),
      imageBuilder: (context, imageProvider) => _buildImageFrame(
        context,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.08),
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildImageFrame(BuildContext context, {BoxDecoration? decoration, Widget? child}) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          width: MediaQuery.of(context).size.width / 3,
          height: double.maxFinite,
          decoration: decoration ?? BoxDecoration(color: Colors.black.withValues(alpha: 0.08)),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTitleAndDescription() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Butler',
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.timeline_outlined, size: 16),
                const SizedBox(width: 4),
                Text(dateText, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}